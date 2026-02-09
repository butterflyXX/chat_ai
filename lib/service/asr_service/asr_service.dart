import 'dart:async';
import 'dart:typed_data';

import 'package:chat_ai/common/common.dart';
import 'package:chat_ai/common/util/log_util.dart';

/// ASR识别结果回调
/// - result: 完整的识别文本（确定性结果 + 当前临时结果）
/// - isFinal: 当前片段是否确定（true=type:0确定性，false=type:1中间）
/// - segId: 当前片段ID

/// 识别结果数据
class RecognitionResult {
  final String text;
  final bool isFinal; // 0-确定性结果；1-中间结果
  final bool isEnd;

  RecognitionResult(this.text, this.isFinal, this.isEnd);
}

/// ASR服务基类
abstract class AsrServiceBase {
  List<RecognitionResult> textList = [];
  Completer? _resultCompleter;

  VoidCallback? _removeListener;

  ValueChanged<String>? onError;

  AsrServiceBase({this.onError});

  /// 开始识别
  Future<void> start() async {
    textList.clear();
    final recordService = ServiceManager.getRecord;

    final recordStarted = await recordService.start();
    if (!recordStarted) {
      LogUtil.d('录音服务启动失败');
      return;
    }

    _removeListener = recordService.listen(sendAudio);
    _resultCompleter = Completer();
    onStart();
  }

  /// 停止识别
  Future<List<RecognitionResult>> stop() async {
    final recordService = ServiceManager.getRecord;
    await recordService.stop();
    _removeListener?.call();
    _removeListener = null;
    onStop();
    await _resultCompleter?.future;
    _resultCompleter = null;
    return textList;
  }

  Future<void> onStart();

  Future<void> onStop();

  Future<void> onResult() async {}

  /// 发送音频数据
  Future<void> sendAudio(Uint8List audioData);

  void addResult(RecognitionResult result) {
    if (textList.isEmpty || textList.last.isFinal) {
      textList.add(result);
    } else {
      textList[textList.length - 1] = result;
    }
    if (_resultCompleter != null && !_resultCompleter!.isCompleted && result.isEnd) {
      _resultCompleter!.complete();
    }
  }
}
