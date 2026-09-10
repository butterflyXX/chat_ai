import 'package:chat_ai/service/ai_service/ai_message_model.dart';

/// 控制发给模型的上下文长度。本地数据库仍保存完整历史。
class ContextWindow {
  /// 最多保留的对话轮数（一问一答算一轮）
  static const int maxTurns = 12;

  /// 估算字符上限（约 4 字符 ≈ 1 token，可按模型调整）
  static const int maxEstimatedChars = 16000;

  static List<AiMessageModel> trim(List<AiMessageModel> messages) {
    final completed = messages.where((m) => m.state == AiMessageState.end).toList();
    if (completed.isEmpty) return completed;

    var totalChars = 0;
    var turns = 0;
    final result = <AiMessageModel>[];

    for (var i = completed.length - 1; i >= 0; i--) {
      final message = completed[i];
      final len = message.message.length + message.reasoningContent.length;

      if (result.isNotEmpty) {
        if (totalChars + len > maxEstimatedChars) break;
        if (turns >= maxTurns) break;
      }

      result.insert(0, message);
      totalChars += len;
      if (message.role == AiMessageRole.user) {
        turns++;
      }
    }

    while (result.isNotEmpty && result.first.role != AiMessageRole.user) {
      result.removeAt(0);
    }

    return result;
  }

  static bool hasTrimmed(List<AiMessageModel> all, List<AiMessageModel> window) {
    final allCompleted = all.where((m) => m.state == AiMessageState.end).length;
    return window.length < allCompleted;
  }
}
