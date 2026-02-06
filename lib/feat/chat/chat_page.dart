import 'package:chat_ai/common/common.dart';
import 'package:chat_ai/feat/chat/chat_input_bar/chat_input_bar.dart';
import 'package:chat_ai/feat/chat/chat_item.dart';
import 'package:chat_ai/service/ai_service/ai_service_qwen.dart';
import 'package:chat_ai/service/ai_service/ai_service_spark.dart';

enum AiServiceType {
  spark(0),
  qwen(1);

  final int value;
  const AiServiceType(this.value);

  AiServiceBase get service => switch (this) {
    AiServiceType.spark => ChatAiServiceSpark(),
    AiServiceType.qwen => ChatAiServiceQwen(),
  };

  static AiServiceType fromValue(int value) {
    return values.firstWhere((e) => e.value == value);
  }

  String displayName(BuildContext context) => switch (this) {
    AiServiceType.spark => S.of(context).spark,
    AiServiceType.qwen => S.of(context).qwen,
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
  final ScrollController _scrollController = ScrollController();

  @override
  initState() {
    super.initState();
    aiService.stream.listen((message) {
      setState(() {});
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeInOut,
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CAAppBar.commonAppbar(context, title: aiServiceType.displayName(context)),
      body: Column(
        children: [
          Expanded(
            child: ShaderMask(
              shaderCallback: (Rect bounds) {
                return const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white, Colors.white, Colors.transparent],
                  stops: [0.0, 0.98, 1.0],
                ).createShader(bounds);
              },
              blendMode: BlendMode.dstIn,
              child: ListView.separated(
                controller: _scrollController,
                padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 16.w),
                itemBuilder: (context, index) {
                  if (aiService.historyMessages[index].role == AiMessageRole.user) {
                    return ChatUserWidget(message: aiService.historyMessages[index]);
                  } else {
                    return ChatAiWidget(message: aiService.historyMessages[index]);
                  }
                },
                itemCount: aiService.historyMessages.length,
                separatorBuilder: (context, index) => SizedBox(height: 16.w),
              ),
            ),
          ),
          ChatBottomBar(onSubmit: aiService.sendMessage),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    aiService.dispose();
  }
}
