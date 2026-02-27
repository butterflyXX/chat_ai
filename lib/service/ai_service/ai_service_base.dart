import 'dart:async';

import 'package:chat_ai/common/util/log_util.dart';

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

  @override
  String toString() {
    return 'AiMessageModel(role: $role, state: $state, message: $message)';
  }
}

abstract class AiServiceBase {
  bool aiing = false;
  final _messageBuffer = StringBuffer();
  final _streamcontroller = StreamController<AiMessageModel>.broadcast();
  final historyMessages = <AiMessageModel>[];
  Stream<AiMessageModel> get stream => _streamcontroller.stream;
  StreamSubscription? currentSubscription;
  Future<void> sendMessage(String message) async {
    _addMessage(AiMessageModel(role: AiMessageRole.user, state: AiMessageState.end, message: message), isUser: true);
    _messageBuffer.clear();
  }

  void reseveMessage(AiMessageState state, String message) {
    LogUtil.d('reseveMessage: $message');
    _messageBuffer.write(message);
    final totalMessage = _messageBuffer.toString();
    final messageModel = AiMessageModel(role: AiMessageRole.assistant, state: state, message: totalMessage);
    switch (state) {
      case AiMessageState.start:
        _addMessage(messageModel);
      case AiMessageState.streaming:
      case AiMessageState.end:
        historyMessages.removeLast();
        _addMessage(messageModel);
    }
  }

  void _addMessage(AiMessageModel messageModel, {bool isUser = false}) {
    historyMessages.add(messageModel);
    if (isUser) {
      aiing = true;
    } else {
      if (messageModel.state == AiMessageState.end) {
        aiing = false;
      }
    }
    _streamcontroller.add(messageModel);
  }

  Future<void> stopAi() async {
    await _cancelSubscription();
    if (!aiing) return;
    aiing = false;

    final lastMessage = historyMessages.last;
    _streamcontroller.add(
      AiMessageModel(role: lastMessage.role, state: AiMessageState.end, message: lastMessage.message),
    );
  }

  Future<void> _cancelSubscription() async {
    await currentSubscription?.cancel();
    currentSubscription = null;
  }

  Future<void> dispose() async {
    await _cancelSubscription();
    await _streamcontroller.close();
  }
}
