import 'package:chat_ai/common/common.dart';
import 'package:chat_ai/database/app_database.dart';
import 'package:chat_ai/route.dart';
import 'package:chat_ai/service/ai_service/ai_service_type.dart';
import 'package:chat_ai/service/service_manager.dart';
import 'package:intl/intl.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _repo = ServiceManager.getChatRepo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CAAppBar.commonAppbar(
        title: S.of(context).home,
        actions: [
          IconButton(
            onPressed: _openNewChat,
            icon: Icon(Icons.add, color: context.appTheme.textPrimary),
          ),
        ],
      ),
      body: StreamBuilder<List<Conversation>>(
        stream: _repo.watchConversations(),
        builder: (context, snapshot) {
          final conversations = snapshot.data ?? [];
          if (conversations.isEmpty) {
            return Center(
              child: Text(
                S.of(context).chatListEmpty,
                style: TextStyleTheme.regular14.copyWith(color: context.appTheme.textSecondary),
              ),
            );
          }
          return ListView.separated(
            padding: EdgeInsets.symmetric(vertical: 8.w),
            itemCount: conversations.length,
            separatorBuilder: (context, index) => SizedBox(height: 8.w),
            itemBuilder: (context, index) => _buildConversationItem(conversations[index]),
          );
        },
      ),
    );
  }

  Widget _buildConversationItem(Conversation conversation) {
    final aiType = AiServiceType.fromValue(conversation.aiServiceType);
    final time = DateFormat('MM-dd HH:mm').format(conversation.updatedAt);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => ChatRoute(aiServiceType: conversation.aiServiceType, conversationId: conversation.id).push(context),
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
        decoration: BoxDecoration(color: context.appTheme.fillsPrimary, borderRadius: BorderRadius.circular(12.r)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              conversation.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyleTheme.medium14.copyWith(color: context.appTheme.textPrimary),
            ),
            SizedBox(height: 4.w),
            Text(
              '${aiType.displayName(context)} · $time',
              style: TextStyleTheme.regular12.copyWith(color: context.appTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  void _openNewChat() {
    ChatRoute(aiServiceType: AiServiceType.agnes.value).push(context);
  }
}
