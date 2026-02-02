import 'package:chat_ai/common/common.dart';
import 'package:chat_ai/feat/chat/chat_item.dart';
import 'package:chat_ai/service/ai_service/ai_service_spark.dart';

enum AiServiceType {
  spark(0);

  final int value;
  const AiServiceType(this.value);

  AiServiceBase get service => switch (this) {
    AiServiceType.spark => ChatAiServiceSpark(),
  };

  static AiServiceType fromValue(int value) {
    return values.firstWhere((e) => e.value == value);
  }

  String displayName(BuildContext context) => switch (this) {
    AiServiceType.spark => S.of(context).spark,
  };
}

class ChatPage extends ConsumerStatefulWidget {
  final int aiServiceType;
  const ChatPage({super.key, required this.aiServiceType});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  late final aiServiceType = AiServiceType.fromValue(widget.aiServiceType);
  late final aiService = aiServiceType.service;
  final List<AiMessageModel> _messages = [];

  @override
  initState() {
    super.initState();
    aiService.stream.listen((message) {
      setState(() {
        switch (message.state) {
          case AiMessageState.start:
            _messages.add(message);
          case AiMessageState.streaming:
          case AiMessageState.end:
            _messages.removeLast();
            _messages.add(message);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CAAppBar.commonAppbar(context, title: aiServiceType.displayName(context)),
      body: ListView.separated(
        padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: ScreenUtil().bottomBarHeight + 16.w),
        itemBuilder: (context, index) {
          return ChatItemAiWidget(message: _messages[index]);
        },
        itemCount: _messages.length,
        separatorBuilder: (context, index) => SizedBox(height: 16.w),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          aiService.sendMessage('帮我写一篇2000字作文,题目随意');
        },
        child: Icon(Icons.send),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    aiService.dispose();
  }
}
