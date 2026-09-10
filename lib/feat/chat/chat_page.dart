import 'dart:async';

import 'package:chat_ai/common/common.dart';
import 'package:chat_ai/feat/chat/chat_input_bar/chat_input_bar.dart';
import 'package:chat_ai/feat/chat/chat_item.dart';
import 'package:chat_ai/service/ai_service/ai_message_model.dart';
import 'package:chat_ai/service/ai_service/ai_service_open_ai.dart';
import 'package:chat_ai/service/ai_service/ai_service_type.dart';
import 'package:chat_ai/service/service_manager.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class ChatPage extends ConsumerStatefulWidget {
  final int aiServiceType;
  final String? conversationId;

  const ChatPage({super.key, required this.aiServiceType, this.conversationId});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  late final aiServiceType = AiServiceType.fromValue(widget.aiServiceType);
  late final AiServiceOpenAi aiService = aiServiceType.service as AiServiceOpenAi;
  final _chatRepo = ServiceManager.getChatRepo;
  final ScrollController _scrollController = ScrollController();
  StreamSubscription<AiMessageModel>? _messageSubscription;

  String? _conversationId;
  bool _isUserScrolling = false;
  bool _isAtBottom = true;
  String? _conversationTitle;

  @override
  void initState() {
    super.initState();
    _conversationId = widget.conversationId;
    _loadHistory();
    _messageSubscription = aiService.stream.listen(_onStreamMessage);
  }

  Future<void> _loadConversationTitle(String message) async {
    final title = await aiService.generateConversationTitle(message);
    if (title == null) return;
    setState(() => _conversationTitle = title);
    await _chatRepo.updateConversationTitle(_conversationId!, title);
  }

  Future<void> _loadHistory() async {
    if (_conversationId == null) return;
    final messages = await _chatRepo.loadMessages(_conversationId!);
    aiService.restoreFromHistory(messages);
    if (mounted) setState(() {});
  }

  void _onStreamMessage(AiMessageModel message) {
    setState(() {});
    unawaited(_persistMessage(message));

    if (message.state == AiMessageState.end) {
      HapticFeedback.lightImpact();
    }
    if (_isUserScrolling || !_isAtBottom) return;
    _scrollToBottom(streaming: message.state == AiMessageState.streaming);
  }

  Future<void> _persistMessage(AiMessageModel message) async {
    if (message.state != AiMessageState.end) return;

    if (message.role == AiMessageRole.user) {
      if (_conversationId == null) {
        _conversationId = await _chatRepo.createConversation(
          aiServiceType: widget.aiServiceType,
          title: message.message,
        );
        _loadConversationTitle(message.message);
        await _chatRepo.saveUserMessage(conversationId: _conversationId!, content: message.message);
      } else {
        await _chatRepo.saveUserMessage(conversationId: _conversationId!, content: message.message);
      }
      return;
    }

    if (_conversationId == null) return;
    await _chatRepo.saveAssistantMessage(
      conversationId: _conversationId!,
      content: message.message,
      reasoningContent: message.reasoningContent,
    );
  }

  void _scrollToBottom({required bool streaming}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      final target = _scrollController.position.maxScrollExtent;
      if (streaming) {
        _scrollController.jumpTo(target);
      } else {
        _scrollController.animateTo(target, duration: const Duration(milliseconds: 100), curve: Curves.easeInOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CAAppBar.commonAppbar(title: _conversationTitle ?? S.of(context).newChat),
      body: Column(
        children: [
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is UserScrollNotification) {
                  if (notification.direction == ScrollDirection.idle) {
                    _isUserScrolling = false;
                    final metrics = notification.metrics;
                    _isAtBottom = metrics.maxScrollExtent - metrics.pixels < 50;
                  } else {
                    _isUserScrolling = true;
                  }
                }
                return false;
              },
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
          ChatBottomBar(onSubmit: aiService.sendMessage, aiing: aiService.aiing, onStop: aiService.stopAi),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _scrollController.dispose();
    aiService.dispose();
    super.dispose();
  }
}
