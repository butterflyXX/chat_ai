import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';

import 'package:chat_ai/app_key.dart';
import 'package:chat_ai/common/util/log_util.dart';
import 'package:chat_ai/service/asr_service/asr_service.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// 讯飞实时语音转写(RTASR)服务实现
class XunfeiAsrService extends AsrServiceBase {
  XunfeiAsrService({super.onError});

  /// 固定参数
  static const String audioEncode = 'pcm_s16le';
  static const String language = 'autodialect';
  static const String sampleRate = '16000';

  /// 音频帧大小（16k采样率、16bit位深、40ms）
  static const int audioFrameSize = 1280;

  /// 帧间隔（毫秒）
  static const int frameIntervalMs = 40;

  WebSocketChannel? _channel;
  bool _isConnected = false;
  String? _sessionId;
  StreamSubscription? _messageSubscription;
  int _lastSendTime = 0; // 上次发送音频的时间戳（毫秒）
  final Queue<Uint8List> _audioBuffer = Queue(); // 音频数据缓冲区

  @override
  Future<void> onStart() async {
    if (_isConnected) {
      LogUtil.d('已经在运行中');
      return;
    }
    try {
      // 生成WebSocket URL
      final url = _createUrl();
      LogUtil.d('连接讯飞RTASR服务');
      LogUtil.d('URL: $url');

      // 建立WebSocket连接
      _channel = WebSocketChannel.connect(Uri.parse(url));
      _isConnected = true;
      _sessionId = null;
      _audioBuffer.clear(); // 清空音频缓冲区
      _lastSendTime = 0; // 重置发送时间

      // 等待连接建立
      await Future.delayed(const Duration(milliseconds: 1500));

      // 监听消息
      _messageSubscription = _channel!.stream.listen(
        _onMessage,
        onError: (error) {
          LogUtil.d('WebSocket错误: $error');
          onError?.call(error.toString());
          _isConnected = false;
        },
        onDone: () {
          LogUtil.d('WebSocket连接关闭');
          _isConnected = false;
        },
      );

      LogUtil.d('启动成功');
    } catch (e) {
      LogUtil.d('启动失败: $e');
      onError?.call(e.toString());
      _isConnected = false;
    }
  }

  @override
  Future<void> onStop() async {
    try {
      if (_isConnected) {
        await _sendEndMarker();
      }
      LogUtil.d('已停止');
    } catch (e) {
      LogUtil.d('停止时出错: $e');
    }
  }

  @override
  Future<void> sendAudio(Uint8List audioData) async {
    if (!_isConnected) {
      return;
    }
    // 录音是80ms一帧,需要拆分成两帧发送
    final frame1 = audioData.sublist(0, audioFrameSize);
    final frame2 = audioData.sublist(audioFrameSize, audioData.length);

    // 将数据添加到缓冲区
    _audioBuffer.add(frame1);
    _audioBuffer.add(frame2);

    // LogUtil.d('缓冲区大小: ${_audioBuffer.length}');

    // 当缓冲区累积到足够的数据时，按帧发送
    while (_audioBuffer.length == 2) {
      _sendFrameWithRateControl().then((value) {
        // LogUtil.d('发送帧完成');
      });
    }
  }

  /// 按照精确的速率发送音频帧
  Future<void> _sendFrameWithRateControl() async {
    // LogUtil.d('发送帧开始: ${_audioBuffer.length}');
    final frame = _audioBuffer.removeFirst();
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    // 计算期望的发送时间
    if (_lastSendTime == 0) {
      // 首次发送
      _lastSendTime = currentTime;
    } else {
      // 计算应该等待的时间
      final expectedTime = _lastSendTime + frameIntervalMs;
      final waitTime = expectedTime - currentTime;

      if (waitTime > 1) {
        // 需要等待，确保严格按照40ms间隔发送
        await Future.delayed(Duration(milliseconds: waitTime));
      }
      _lastSendTime = expectedTime;
    }

    try {
      // 直接发送二进制音频数据
      _channel!.sink.add(frame);
      if (_audioBuffer.isNotEmpty) {
        _sendFrameWithRateControl();
      }
    } catch (e) {
      LogUtil.d('发送音频帧失败: $e');
      onError?.call(e.toString());
    }
  }

  /// 发送结束标记
  Future<void> _sendEndMarker() async {
    if (_channel == null) return;

    try {
      final endMsg = <String, dynamic>{'end': true};
      if (_sessionId != null) {
        endMsg['sessionId'] = _sessionId;
      }

      final endMsgStr = jsonEncode(endMsg);
      _channel!.sink.add(endMsgStr);
      LogUtil.d('发送结束标记: $endMsgStr');
    } catch (e) {
      LogUtil.d('发送结束标记失败: $e');
    }
  }

  /// 处理接收到的消息
  void _onMessage(dynamic message) {
    try {
      // 仅处理文本消息（JSON格式）
      if (message is String) {
        final msgJson = jsonDecode(message) as Map<String, dynamic>;
        LogUtil.d('收到消息: $msgJson');

        final data = msgJson['data'] as Map<String, dynamic>?;

        if (data == null) return;

        final action = data['action'] as String?;

        // 检查 data 中的错误码
        final dataCode = data['code'];
        if (dataCode != null && int.parse(dataCode.toString()) != 0) {
          final errorMsg = data['message'] as String? ?? '未知错误';
          LogUtil.d('错误码: $dataCode, 消息: $errorMsg');
          onError?.call('错误码: $dataCode - $errorMsg');
          _closeConnection();
          return;
        }

        // 更新会话ID
        if (action == 'started') {
          if (data.containsKey('sessionId')) {
            _sessionId = data['sessionId'] as String;
            LogUtil.d('会话ID: $_sessionId');
          }
          return;
        }

        // 解析识别结果
        final result = _extractRecognitionResult(data);
        if (result != null && result.text.isNotEmpty) {
          LogUtil.d('asr结果: ${result.text}, isFinal: ${result.isFinal} isEnd: ${result.isEnd}');
          addResult(result);
        }
      } else if (message is List<int>) {
        // 忽略二进制消息
        LogUtil.d('收到二进制消息，长度: ${message.length}');
      }
    } catch (e) {
      LogUtil.d('解析消息失败: $e');
      onError?.call('解析错误: $e');
    }
  }

  /// 从嵌套结构中提取识别结果
  /// 结构: data.cn.st.type, data.cn.st.rt[].ws[].cw[].w
  RecognitionResult? _extractRecognitionResult(Map<String, dynamic> data) {
    try {
      final isEnd = data['ls'] as bool? ?? false;
      final cn = data['cn'] as Map<String, dynamic>?;
      if (cn == null) return null;

      final st = cn['st'] as Map<String, dynamic>?;
      if (st == null) return null;

      // 获取type: 0-确定性结果；1-中间结果
      final type = int.tryParse(st['type'].toString()) ?? 1;

      final rt = st['rt'] as List<dynamic>?;
      if (rt == null || rt.isEmpty) return null;

      final resultText = StringBuffer();

      for (final rtItem in rt) {
        final ws = rtItem['ws'] as List<dynamic>?;
        if (ws == null) continue;

        for (final wsItem in ws) {
          Object? wbObj = wsItem["wb"];
          if (null == wbObj) {
            return null;
          }
          Object? weObj = wsItem["we"];
          if (null == weObj) {
            return null;
          }
          final cw = wsItem['cw'] as List<dynamic>?;
          if (cw == null) continue;

          for (final cwItem in cw) {
            final w = cwItem["w"] as String?;
            if (null == w) {
              return null;
            }
            final wp = cwItem["wp"] as String?;
            if (null == wp) {
              return null;
            }
            if (w.isNotEmpty) {
              resultText.write(w);
            }
          }
        }
      }

      return RecognitionResult(resultText.toString(), type == 0 ? true : false, isEnd);
    } catch (e) {
      LogUtil.d('提取识别结果失败: $e');
      return null;
    }
  }

  /// 生成WebSocket连接URL
  String _createUrl() {
    const baseWsUrl = 'wss://office-api-ast-dx.iflyaisol.com/ast/communicate/v1';

    // 生成鉴权参数
    final authParams = _generateAuthParams();

    // URL编码参数
    final queryString = authParams.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');

    return '$baseWsUrl?$queryString';
  }

  /// 生成鉴权参数（严格按字典序排序）
  Map<String, String> _generateAuthParams() {
    final uuid = const Uuid().v4().replaceAll('-', '');
    final utc = _getUtcTime();

    // 基础参数
    final authParams = <String, String>{
      'accessKeyId': xfAccessKeyId,
      'appId': xfAppId,
      'uuid': uuid,
      'utc': utc,
      'audio_encode': audioEncode,
      'lang': language,
      'samplerate': sampleRate,
    };

    // 过滤空值并按字典序排序
    final sortedParams = Map.fromEntries(
      authParams.entries.where((e) => e.value.isNotEmpty).toList()..sort((a, b) => a.key.compareTo(b.key)),
    );

    // 构建基础字符串（URL编码）
    final baseStr = sortedParams.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');

    // HMAC-SHA1加密
    final hmacSha1 = Hmac(sha1, utf8.encode(xfAccessKeySecret));
    final signature = hmacSha1.convert(utf8.encode(baseStr));
    authParams['signature'] = base64Encode(signature.bytes);

    return authParams;
  }

  /// 生成UTC时间格式：yyyy-MM-dd'T'HH:mm:ss+0800
  String _getUtcTime() {
    final now = DateTime.now();
    final year = now.year.toString().padLeft(4, '0');
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    final second = now.second.toString().padLeft(2, '0');

    // 获取时区偏移
    final offset = now.timeZoneOffset;
    final offsetHours = offset.inHours.abs().toString().padLeft(2, '0');
    final offsetMinutes = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
    final offsetSign = offset.isNegative ? '-' : '+';

    return '$year-$month-${day}T$hour:$minute:$second$offsetSign$offsetHours$offsetMinutes';
  }

  /// 关闭WebSocket连接
  Future<void> _closeConnection() async {
    try {
      _isConnected = false;
      await _messageSubscription?.cancel();
      _messageSubscription = null;
      await _channel?.sink.close();
      _channel = null;
      _sessionId = null;
      LogUtil.d('WebSocket连接已关闭');
    } catch (e) {
      LogUtil.d('关闭连接时出错: $e');
    }
  }
}
