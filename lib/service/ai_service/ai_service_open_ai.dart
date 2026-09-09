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
      await _runStreamLoop();
    } catch (e) {
      LogUtil.d('发送消息失败: $e');
      reseveMessage(AiMessageState.end, '');
      rethrow;
    }
  }

  /// 全程走 stream：指令轮和最终回复都边收边拼到同一条气泡。
  /// 流结束后若有 tool_calls，本地执行工具再继续下一轮。
  Future<void> _runStreamLoop() async {
    var isFirstRound = true;

    while (true) {
      final round = await _streamOneRound(startMessage: isFirstRound);
      isFirstRound = false;

      if (round.toolCalls.isEmpty) {
        _chatMessages.add(AIChatMessage(content: round.content));
        reseveMessage(AiMessageState.end, '');
        return;
      }

      await _handleToolCalls(round.toolCalls, content: round.content);
    }
  }

  Future<({String content, List<AIChatMessageToolCall> toolCalls})> _streamOneRound({
    required bool startMessage,
  }) async {
    var accumulated = const AIChatMessage(content: '');
    final completer = Completer<void>();
    final tools = _toolManager.getToolDefinitions();

    if (startMessage) reseveMessage(AiMessageState.start, '');

    currentSubscription = _chat
        .stream(
          PromptValue.chat(_chatMessages),
          options: ChatOpenAIOptions(tools: tools),
        )
        .listen(
          (result) {
            accumulated = accumulated.concat(result.output);
            final delta = result.output.content;
            if (delta.isNotEmpty) reseveMessage(AiMessageState.streaming, delta);
          },
          onError: (e) {
            LogUtil.d('Stream 错误: $e');
            currentSubscription = null;
            if (!completer.isCompleted) completer.completeError(e);
          },
          onDone: () {
            LogUtil.d('Stream 完成');
            currentSubscription = null;
            if (!completer.isCompleted) completer.complete();
          },
          cancelOnError: false,
        );

    await completer.future;

    final toolCalls = accumulated.toolCalls.where((tc) => tc.name.isNotEmpty).toList(growable: false);
    return (content: accumulated.content, toolCalls: toolCalls);
  }

  Future<void> _handleToolCalls(List<AIChatMessageToolCall> toolCalls, {required String content}) async {
    LogUtil.d('工具调用: ${toolCalls.map((t) => t.name).toList()}');
    _chatMessages.add(AIChatMessage(content: content, toolCalls: toolCalls));

    for (final tc in toolCalls) {
      final toolResult = await _toolManager.executeTool(tc.name, jsonEncode(_toolCallArguments(tc)));
      LogUtil.d('工具 ${tc.name} 结果: $toolResult');
      _chatMessages.add(ChatMessage.tool(toolCallId: tc.id, content: toolResult));
    }
  }

  Map<String, dynamic> _toolCallArguments(AIChatMessageToolCall tc) {
    if (tc.arguments.isNotEmpty) return tc.arguments;
    if (tc.argumentsRaw.isEmpty) return {};
    try {
      final decoded = jsonDecode(tc.argumentsRaw);
      return decoded is Map<String, dynamic> ? decoded : {};
    } catch (_) {
      return {};
    }
  }

  @override
  Future<void> dispose() async {
    _chat.close();
    await super.dispose();
  }
}
