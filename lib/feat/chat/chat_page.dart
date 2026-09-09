import 'dart:async';

import 'package:chat_ai/common/common.dart';
import 'package:chat_ai/feat/chat/chat_input_bar/chat_input_bar.dart';
import 'package:chat_ai/feat/chat/chat_item.dart';
import 'package:chat_ai/service/ai_service/ai_message_model.dart';
import 'package:chat_ai/service/ai_service/ai_service_type.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

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
  StreamSubscription<AiMessageModel>? _messageSubscription;

  bool _isUserScrolling = false;
  bool _isAtBottom = true;

  @override
  initState() {
    super.initState();
    _messageSubscription = aiService.stream.listen((message) {
      setState(() {});
      if (message.state == AiMessageState.end) {
        HapticFeedback.lightImpact();
      }
      if (_isUserScrolling || !_isAtBottom) return;
      _scrollToBottom(streaming: message.state == AiMessageState.streaming);
    });
  }

  void _scrollToBottom({required bool streaming}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      final target = _scrollController.position.maxScrollExtent;
      // 流式输出用 jumpTo，避免 animateTo 与高频 rebuild 叠加导致 Android 卡死
      if (streaming) {
        _scrollController.jumpTo(target);
      } else {
        _scrollController.animateTo(
          target,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeInOut,
        );
      }
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
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is UserScrollNotification) {
                    if (notification.direction == ScrollDirection.idle) {
                      // 确定是【用户】在滑，记录状态，暂停你的自动滚动逻辑
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
