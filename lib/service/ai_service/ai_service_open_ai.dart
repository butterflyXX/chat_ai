import 'dart:async';
import 'dart:convert';
import 'package:chat_ai/common/util/log_util.dart';
import 'package:chat_ai/service/ai_service/ai_service_base.dart';
import 'package:chat_ai/tools/tool_manager.dart';
import 'package:http/http.dart' as http;
import 'package:openai_dart/openai_dart.dart';

export 'package:chat_ai/service/ai_service/ai_service_base.dart';

class AiServiceOpenAi extends AiServiceBase {
  final String apiKey;
  final String baseUrl;
  final String model;

  final _toolManager = ToolManager();
  final OpenAIClient _client;

  /// API 侧完整消息历史（含 tool role 消息，不直接展示到 UI）
  final List<ChatMessage> _chatMessages = [];

  AiServiceOpenAi({
    required this.apiKey,
    required this.baseUrl,
    required this.model,
    http.Client? client,
  }) : _client = OpenAIClient.withApiKey(
         apiKey,
         baseUrl: baseUrl,
         httpClient: client,
       );

  @override
  Future<void> sendMessage(String message) async {
    await super.sendMessage(message);
    await currentSubscription?.cancel();
    currentSubscription = null;

    _chatMessages.add(ChatMessage.user(message));

    try {
      await _runStreamLoop();
    } catch (e) {
      LogUtil.d('发送消息失败: $e');
      reseveMessage(AiMessageState.end, '');
      rethrow;
    }
  }

  /// 全程走 Chat Completions stream；content 边收边展示，流结束后处理 tool_calls。
  Future<void> _runStreamLoop() async {
    var isFirstRound = true;

    while (true) {
      final round = await _streamOneRound(startMessage: isFirstRound);
      isFirstRound = false;

      if (round.toolCalls.isEmpty) {
        _chatMessages.add(ChatMessage.assistant(content: round.content));
        reseveMessage(AiMessageState.end, '');
        return;
      }

      await _handleToolCalls(round.toolCalls, content: round.content);
    }
  }

  Future<({String content, List<ToolCall> toolCalls})> _streamOneRound({
    required bool startMessage,
  }) async {
    final accumulator = ChatStreamAccumulator();
    final completer = Completer<void>();

    if (startMessage) reseveMessage(AiMessageState.start, '');

    final request = ChatCompletionCreateRequest(
      model: model,
      messages: List<ChatMessage>.from(_chatMessages),
      tools: _toolManager.getToolDefinitions(),
    );

    currentSubscription = _client.chat.completions.createStream(request).listen(
      (event) {
        accumulator.add(event);
        final delta = event.firstChoice?.delta;
        final contentDelta = event.textDelta;
        final reasoningDelta = delta?.reasoningContent ?? delta?.reasoning;
        if ((contentDelta != null && contentDelta.isNotEmpty) ||
            (reasoningDelta != null && reasoningDelta.isNotEmpty)) {
          reseveMessage(
            AiMessageState.streaming,
            contentDelta ?? '',
            reasoningContent: reasoningDelta ?? '',
          );
        }
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

    final toolCalls = accumulator.toolCalls
        .where((tc) => tc.function.name.isNotEmpty)
        .toList(growable: false);
    return (content: accumulator.content, toolCalls: toolCalls);
  }

  Future<void> _handleToolCalls(List<ToolCall> toolCalls, {required String content}) async {
    LogUtil.d('工具调用: ${toolCalls.map((t) => t.function.name).toList()}');
    _chatMessages.add(
      ChatMessage.assistant(
        content: content.isEmpty ? null : content,
        toolCalls: toolCalls,
      ),
    );

    for (final tc in toolCalls) {
      final toolResult = await _toolManager.executeTool(
        tc.function.name,
        jsonEncode(_toolCallArguments(tc)),
      );
      LogUtil.d('工具 ${tc.function.name} 结果: $toolResult');
      _chatMessages.add(ChatMessage.tool(toolCallId: tc.id, content: toolResult));
    }
  }

  Map<String, dynamic> _toolCallArguments(ToolCall tc) {
    final raw = tc.function.arguments;
    if (raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? decoded : {};
    } catch (_) {
      return {};
    }
  }

  @override
  Future<void> dispose() async {
    _client.close();
    await super.dispose();
  }
}
