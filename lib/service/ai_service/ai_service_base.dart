import 'dart:async';

import 'ai_message_model.dart';

abstract class AiServiceBase {
  bool aiing = false;
  final _messageBuffer = StringBuffer();
  final _reasoningBuffer = StringBuffer();
  final _streamcontroller = StreamController<AiMessageModel>.broadcast();
  final historyMessages = <AiMessageModel>[];
  Stream<AiMessageModel> get stream => _streamcontroller.stream;
  StreamSubscription? currentSubscription;

  Timer? _streamEmitTimer;
  static const _streamEmitInterval = Duration(milliseconds: 100);

  Future<void> sendMessage(String message) async {
    _cancelStreamEmitTimer();
    _addMessage(AiMessageModel(role: AiMessageRole.user, state: AiMessageState.end, message: message), isUser: true);
    _messageBuffer.clear();
    _reasoningBuffer.clear();
  }

  /// [message] 正式回答内容增量，[reasoningContent] 思考链增量
  void reseveMessage(AiMessageState state, String message, {String reasoningContent = ''}) {
    _messageBuffer.write(message);
    _reasoningBuffer.write(reasoningContent);
    final messageModel = AiMessageModel(
      role: AiMessageRole.assistant,
      state: state,
      message: _messageBuffer.toString(),
      reasoningContent: _reasoningBuffer.toString(),
    );
    switch (state) {
      case AiMessageState.start:
        historyMessages.add(messageModel);
      case AiMessageState.streaming:
      case AiMessageState.end:
        historyMessages.removeLast();
        historyMessages.add(messageModel);
        if (state == AiMessageState.end) {
          aiing = false;
        }
    }
    _scheduleStreamEmit(immediate: state != AiMessageState.streaming);
  }

  void _scheduleStreamEmit({required bool immediate}) {
    if (immediate) {
      _cancelStreamEmitTimer();
      _emitLatestAssistantMessage();
      return;
    }
    if (_streamEmitTimer?.isActive ?? false) return;
    _streamEmitTimer = Timer(_streamEmitInterval, () {
      _streamEmitTimer = null;
      _emitLatestAssistantMessage();
    });
  }

  void _emitLatestAssistantMessage() {
    if (historyMessages.isEmpty) return;
    final last = historyMessages.last;
    if (last.role != AiMessageRole.assistant) return;
    _streamcontroller.add(last);
  }

  void _cancelStreamEmitTimer() {
    _streamEmitTimer?.cancel();
    _streamEmitTimer = null;
  }

  void _addMessage(AiMessageModel messageModel, {bool isUser = false}) {
    historyMessages.add(messageModel);
    if (isUser) {
      aiing = true;
    }
    _streamcontroller.add(messageModel);
  }

  Future<void> stopAi() async {
    await _cancelSubscription();
    _cancelStreamEmitTimer();
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
    _cancelStreamEmitTimer();
    await _cancelSubscription();
    await _streamcontroller.close();
  }
}
