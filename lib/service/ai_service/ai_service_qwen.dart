import 'dart:async';
import 'dart:convert';
import 'package:chat_ai/app_key.dart';
import 'package:chat_ai/common/util/log_util.dart';
import 'package:chat_ai/service/ai_service/ai_service_base.dart';
import 'package:dio/dio.dart';

export 'package:chat_ai/service/ai_service/ai_service_base.dart';

class ChatAiServiceQwen extends AiServiceBase {
  final _dio = Dio();

  @override
  Future<void> sendMessage(String message) async {
    await super.sendMessage(message);

    // 取消之前的订阅，避免多个 Stream 同时监听
    await currentSubscription?.cancel();
    currentSubscription = null;

    try {
      _dio.options.headers['Authorization'] = 'Bearer $qwenAppKey';
      _dio.options.responseType = ResponseType.stream;
      final response = await _dio.post(
        'https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions',
        data: {
          'model': 'qwen-plus',
          "stream": true,
          'messages': [
            ...historyMessages.map((e) => {'role': e.role.name, 'content': e.message}),
          ],
        },
      );

      if (response.data?.stream != null) {
        processQwenStream(response.data!.stream);
      } else {
        LogUtil.d("响应数据为空");
        reseveMessage(AiMessageState.end, '');
      }
    } catch (e) {
      LogUtil.d("发送消息失败: $e");
      reseveMessage(AiMessageState.end, '');
      rethrow;
    }
  }

  void processQwenStream(Stream<List<int>> byteStream) {
    reseveMessage(AiMessageState.start, '');

    final lineStream = utf8.decoder.bind(byteStream).transform(const LineSplitter());

    currentSubscription = lineStream.listen(
      (line) {
        try {
          _processLine(line);
        } catch (e) {
          LogUtil.d("处理行数据出错: $e, line: $line");
        }
      },
      onError: (error) {
        LogUtil.d("Stream 错误: $error");
        reseveMessage(AiMessageState.end, '');
      },
      onDone: () {
        LogUtil.d("Stream 完成");
        reseveMessage(AiMessageState.end, '');
        currentSubscription = null;
      },
      cancelOnError: false, // 不因错误自动取消，继续处理后续数据
    );
  }

  void _processLine(String line) {
    final trimmedLine = line.trim();
    if (trimmedLine.isEmpty) return;

    if (trimmedLine == "data: [DONE]" || trimmedLine.startsWith("data: [DONE]")) {
      reseveMessage(AiMessageState.end, '');
      return;
    }

    if (trimmedLine.startsWith("data: ")) {
      if (trimmedLine.length <= 6) {
        LogUtil.d("数据行格式错误，长度不足: $trimmedLine");
        return;
      }

      try {
        final jsonString = trimmedLine.substring(6).trim();
        if (jsonString.isEmpty) return;

        final dynamic decoded = jsonDecode(jsonString);

        if (decoded is! Map<String, dynamic>) {
          LogUtil.d("JSON 不是 Map 类型: $decoded");
          return;
        }

        final choices = decoded['choices'];
        if (choices == null) return;

        if (choices is! List || choices.isEmpty) return;

        final firstChoice = choices[0];
        if (firstChoice is! Map<String, dynamic>) return;

        final delta = firstChoice['delta'];
        if (delta == null) return;

        if (delta is Map<String, dynamic>) {
          final content = delta['content'];
          if (content != null && content is String) {
            reseveMessage(AiMessageState.streaming, content);
          }
        }
      } catch (e) {
        LogUtil.d("解析 JSON 出错: $e, line: $trimmedLine");
      }
    }
  }

  @override
  Future<void> dispose() async {
    await super.dispose();
  }
}
