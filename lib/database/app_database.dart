import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class Conversations extends Table {
  TextColumn get id => text()();
  IntColumn get aiServiceType => integer()();
  TextColumn get title => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class ChatMessages extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get conversationId => text().references(Conversations, #id, onDelete: KeyAction.cascade)();
  TextColumn get role => text()();
  TextColumn get content => text()();
  TextColumn get reasoningContent => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();
}

@DriftDatabase(tables: [Conversations, ChatMessages])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'chat_ai');
  }

  Stream<List<Conversation>> watchConversations() {
    return (select(conversations)..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])).watch();
  }

  Future<Conversation?> getConversation(String id) {
    return (select(conversations)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<void> insertConversation(ConversationsCompanion entry) {
    return into(conversations).insert(entry);
  }

  Future<void> updateConversationTitleAndTime(String id, String title, DateTime updatedAt) {
    return (update(
      conversations,
    )..where((t) => t.id.equals(id))).write(ConversationsCompanion(title: Value(title), updatedAt: Value(updatedAt)));
  }

  Future<void> touchConversation(String id, DateTime updatedAt) {
    return (update(
      conversations,
    )..where((t) => t.id.equals(id))).write(ConversationsCompanion(updatedAt: Value(updatedAt)));
  }

  Future<List<ChatMessage>> getMessages(String conversationId) {
    return (select(chatMessages)
          ..where((t) => t.conversationId.equals(conversationId))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  Future<int> insertMessage(ChatMessagesCompanion entry) {
    return into(chatMessages).insert(entry);
  }

  Future<void> deleteConversation(String id) {
    return (delete(conversations)..where((t) => t.id.equals(id))).go();
  }
}
