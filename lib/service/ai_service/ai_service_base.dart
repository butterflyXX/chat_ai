import 'dart:async';

enum AiMessageState {
  start(0),
  streaming(1),
  end(2);

  final int value;
  const AiMessageState(this.value);

  static AiMessageState fromValue(int value) {
    return values.firstWhere((e) => e.value == value);
  }
}

enum AiMessageRole { user, assistant }

class AiMessageModel {
  final AiMessageRole role;
  final AiMessageState state;
  String message;

  AiMessageModel({required this.role, required this.state, required this.message});
}

abstract class AiServiceBase {
  final _messageBuffer = StringBuffer();
  final _streamcontroller = StreamController.broadcast();
  final historyMessages = <AiMessageModel>[];
  Stream get stream => _streamcontroller.stream;
  Future<void> sendMessage(String message) async {
    historyMessages.add(AiMessageModel(role: AiMessageRole.user, state: AiMessageState.end, message: message));
    _messageBuffer.clear();
  }

  void reseveMessage(AiMessageState state, String message) {
    _messageBuffer.write(message);
    final totalMessage = _messageBuffer.toString();
    final messageModel = AiMessageModel(role: AiMessageRole.assistant, state: state, message: totalMessage);
    switch (state) {
      case AiMessageState.start:
        historyMessages.add(messageModel);
      case AiMessageState.streaming:
      case AiMessageState.end:
        historyMessages.removeLast();
        historyMessages.add(messageModel);
    }
    _streamcontroller.add(messageModel);
  }

  Future<void> dispose() async {
    await _streamcontroller.close();
  }
}
