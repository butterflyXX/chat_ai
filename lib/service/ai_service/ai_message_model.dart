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

  /// 模型的思考链内容（仅部分推理模型返回，如 qwen3.7-plus）
  String reasoningContent;

  AiMessageModel({required this.role, required this.state, required this.message, this.reasoningContent = ''});

  @override
  String toString() {
    return 'AiMessageModel(role: $role, state: $state, message: $message, reasoningContent: $reasoningContent)';
  }
}
