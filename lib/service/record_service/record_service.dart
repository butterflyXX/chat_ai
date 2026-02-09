import 'dart:async';
import 'dart:typed_data';

import 'package:chat_ai/common/util/log_util.dart';
import 'package:chat_ai/service/record_service/record_service_base.dart';
import 'package:record/record.dart';

export 'package:chat_ai/service/record_service/record_service_base.dart';

class RecordService extends RecordServiceBase {
  final record = AudioRecorder();

  StreamSubscription<Uint8List>? _subscription;

  @override
  Future<bool> start() async {
    final hasPermission = await record.hasPermission();
    if (!hasPermission) {
      LogUtil.d('没有录音权限');
      return false;
    }

    try {
      // 配置录音参数：16000Hz采样率，单声道，16bit PCM
      const config = RecordConfig(
        encoder: AudioEncoder.pcm16bits, // PCM 16bit编码
        sampleRate: 16000, // 16000Hz采样率（必须！）
        numChannels: 1, // 单声道（必须！）
      );

      final stream = await record.startStream(config);
      _subscription = stream.listen((data) {
        add(data);
      });

      LogUtil.d('录音服务启动成功');
      return true;
    } catch (e) {
      LogUtil.d('启动失败: $e');
      return false;
    }
  }

  @override
  Future<bool> stop() async {
    try {
      await record.stop();
      await _subscription?.cancel();
      _subscription = null;
      LogUtil.d('录音服务已停止');
      return true;
    } catch (e) {
      LogUtil.d('停止失败: $e');
      return false;
    }
  }
}
