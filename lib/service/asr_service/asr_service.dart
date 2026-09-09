import 'dart:async';
import 'dart:typed_data';

import 'package:chat_ai/common/common.dart';
import 'package:chat_ai/common/util/log_util.dart';

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
  StreamSubscription? _removeListener;
  ValueChanged<String>? onError;

  AsrServiceBase({this.onError});

  Future<void> start() async {
    textList.clear();
    final recordService = ServiceManager.getRecord;

    final recordStarted = await recordService.start();
    if (!recordStarted) {
      LogUtil.d('录音服务启动失败');
      return;
    }

    _removeListener = recordService.audioStream.listen(sendAudio);
    _resultCompleter = Completer();
    onStart();
  }

  Future<List<RecognitionResult>> stop() async {
    final recordService = ServiceManager.getRecord;
    await recordService.stop();
    await _removeListener?.cancel();
    _removeListener = null;
    onStop();
    await _resultCompleter?.future;
    _resultCompleter = null;
    return textList;
  }

  Future<void> onStart();
  Future<void> onStop();
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

  void completeSessionIfNeeded() {
    if (_resultCompleter != null && !_resultCompleter!.isCompleted) {
      _resultCompleter!.complete();
    }
  }
}
