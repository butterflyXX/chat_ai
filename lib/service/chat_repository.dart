import 'package:chat_ai/database/app_database.dart';
import 'package:chat_ai/service/ai_service/ai_message_model.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

class ChatRepository {
  ChatRepository(this._db);

  final AppDatabase _db;
  final _uuid = const Uuid();

  Stream<List<Conversation>> watchConversations() => _db.watchConversations();

  Future<Conversation?> getConversation(String id) => _db.getConversation(id);

  Future<List<AiMessageModel>> loadMessages(String conversationId) async {
    final rows = await _db.getMessages(conversationId);
    return rows
        .map(
          (row) => AiMessageModel(
            role: row.role == 'user' ? AiMessageRole.user : AiMessageRole.assistant,
            state: AiMessageState.end,
            message: row.content,
            reasoningContent: row.reasoningContent,
          ),
        )
        .toList();
  }

  Future<String> createConversation({required int aiServiceType, String? title}) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    await _db.insertConversation(
      ConversationsCompanion.insert(
        id: id,
        aiServiceType: aiServiceType,
        title: title ?? '新对话',
        createdAt: now,
        updatedAt: now,
      ),
    );
    return id;
  }

  Future<void> saveUserMessage({
    required String conversationId,
    required String content,
    String? titleIfNew,
  }) async {
    final now = DateTime.now();
    await _db.insertMessage(
      ChatMessagesCompanion.insert(
        conversationId: conversationId,
        role: 'user',
        content: content,
        createdAt: now,
      ),
    );
    if (titleIfNew != null) {
      await _db.updateConversationTitleAndTime(conversationId, titleIfNew, now);
    } else {
      await _db.touchConversation(conversationId, now);
    }
  }

  Future<void> saveAssistantMessage({
    required String conversationId,
    required String content,
    String reasoningContent = '',
  }) async {
    final now = DateTime.now();
    await _db.insertMessage(
      ChatMessagesCompanion.insert(
        conversationId: conversationId,
        role: 'assistant',
        content: content,
        reasoningContent: Value(reasoningContent),
        createdAt: now,
      ),
    );
    await _db.touchConversation(conversationId, now);
  }

  Future<void> deleteConversation(String id) => _db.deleteConversation(id);

  String titleFromFirstMessage(String message) {
    final trimmed = message.trim();
    if (trimmed.isEmpty) return '新对话';
    return trimmed.length > 24 ? '${trimmed.substring(0, 24)}…' : trimmed;
  }
}
