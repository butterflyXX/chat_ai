import 'dart:async';
import 'dart:convert';
import 'package:chat_ai/common/util/log_util.dart';
import 'package:chat_ai/service/ai_service/ai_service_base.dart';
import 'package:chat_ai/tools/tool_manager.dart';
import 'package:http/http.dart' as http;
import 'package:langchain_core/chat_models.dart';
import 'package:langchain_core/prompts.dart';
import 'package:langchain_openai/langchain_openai.dart';

export 'package:chat_ai/service/ai_service/ai_service_base.dart';

class AiServiceOpenAi extends AiServiceBase {
  final String apiKey;
  final String baseUrl;
  final String model;

  final _toolManager = ToolManager();

  /// API 侧完整消息历史（含 tool role 消息，不直接展示到 UI）
  final List<ChatMessage> _chatMessages = [];

  late final ChatOpenAI _chat;

  AiServiceOpenAi({
    required this.apiKey,
    required this.baseUrl,
    required this.model,
    http.Client? client,
  }) {
    _chat = ChatOpenAI(
      apiKey: apiKey,
      baseUrl: baseUrl,
      client: client,
      defaultOptions: ChatOpenAIOptions(model: model),
    );
  }

  @override
  Future<void> sendMessage(String message) async {
    await super.sendMessage(message);
    await currentSubscription?.cancel();
    currentSubscription = null;

    _chatMessages.add(HumanChatMessage(content: ChatMessageContent.text(message)));

    try {
      // 第一步：用 invoke() 静默处理所有工具调用轮次（用户不感知）
      await _resolveToolCalls();
      // 第二步：工具全部就绪后，流式输出最终回答
      _streamFinalResponse();
    } catch (e) {
      LogUtil.d('发送消息失败: $e');
      reseveMessage(AiMessageState.end, '');
      rethrow;
    }
  }

  /// 循环调用 invoke() 直到模型不再请求工具为止
  Future<void> _resolveToolCalls() async {
    final tools = _toolManager.getToolDefinitions();
    while (true) {
      final result = await _chat.invoke(
        PromptValue.chat(_chatMessages),
        options: ChatOpenAIOptions(tools: tools),
      );
      final toolCalls = result.output.toolCalls;
      if (toolCalls.isEmpty) break;

      LogUtil.d('工具调用: ${toolCalls.map((t) => t.name).toList()}');
      _chatMessages.add(AIChatMessage(content: '', toolCalls: toolCalls));

      for (final tc in toolCalls) {
        final toolResult = await _toolManager.executeTool(tc.name, jsonEncode(tc.arguments));
        LogUtil.d('工具 ${tc.name} 结果: $toolResult');
        _chatMessages.add(ChatMessage.tool(toolCallId: tc.id, content: toolResult));
      }
    }
  }

  /// 流式输出最终回答到 UI
  void _streamFinalResponse() {
    reseveMessage(AiMessageState.start, '');
    currentSubscription = _chat
        .stream(PromptValue.chat(_chatMessages))
        .listen(
          (result) {
            final content = result.output.content;
            if (content.isNotEmpty) reseveMessage(AiMessageState.streaming, content);
          },
          onError: (e) {
            LogUtil.d('Stream 错误: $e');
            reseveMessage(AiMessageState.end, '');
          },
          onDone: () {
            LogUtil.d('Stream 完成');
            reseveMessage(AiMessageState.end, '');
            _chatMessages.add(AIChatMessage(content: historyMessages.last.message));
            currentSubscription = null;
          },
          cancelOnError: false,
        );
  }

  @override
  Future<void> dispose() async {
    _chat.close();
    await super.dispose();
  }
}
