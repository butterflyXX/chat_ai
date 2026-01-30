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

class AiMessageModel {
  final AiMessageState state;
  String message;

  AiMessageModel({required this.state, required this.message});

  void addMessage(String message) {
    this.message += message;
  }
}

abstract class AiServiceBase {
  final messageBuffer = StringBuffer();
  final streamcontroller = StreamController<AiMessageModel>.broadcast();
  Stream<AiMessageModel> get stream => streamcontroller.stream;
  Future<void> sendMessage(String message);
  Future<void> dispose() async {
    await streamcontroller.close();
  }
}
