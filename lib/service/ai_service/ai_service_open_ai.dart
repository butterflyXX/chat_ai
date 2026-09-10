import 'dart:async';
import 'package:chat_ai/common/util/log_util.dart';
import 'package:chat_ai/service/ai_service/ai_service_base.dart';
import 'package:chat_ai/tools/tool_manager.dart';
import 'package:http/http.dart' as http;
import 'package:openai_dart/openai_dart.dart';

import 'ai_message_model.dart';
import 'context_window.dart';

export 'package:chat_ai/service/ai_service/ai_service_base.dart';

class AiServiceOpenAi extends AiServiceBase {
  final String apiKey;
  final String baseUrl;
  final String model;

  final _toolManager = ToolManager();
  final OpenAIClient _client;

  /// Responses API 侧完整 input items（含 function_call / function_call_output）
  final List<Item> _inputItems = [];

  AiServiceOpenAi({required this.apiKey, required this.baseUrl, required this.model, http.Client? client})
    : _client = OpenAIClient.withApiKey(apiKey, baseUrl: baseUrl, httpClient: client);

  void restoreFromHistory(List<AiMessageModel> messages) {
    historyMessages
      ..clear()
      ..addAll(messages);
    _rebuildInputItemsForApi();
  }

  /// 仅把窗口内的历史写入 API input；UI 仍展示完整 historyMessages。
  void _rebuildInputItemsForApi() {
    _inputItems.clear();
    final window = ContextWindow.trim(historyMessages);
    if (ContextWindow.hasTrimmed(historyMessages, window)) {
      LogUtil.d('上下文已裁剪: 发送 ${window.length} 条 / 本地 ${historyMessages.length} 条');
    }
    for (final message in window) {
      if (message.role == AiMessageRole.user) {
        _inputItems.add(MessageItem.userText(message.message));
      } else if (message.message.isNotEmpty) {
        _inputItems.add(MessageItem.assistantText(message.message));
      }
    }
  }

  @override
  Future<void> sendMessage(String message) async {
    await super.sendMessage(message);
    await currentSubscription?.cancel();
    currentSubscription = null;

    _rebuildInputItemsForApi();

    try {
      await _runStreamLoop();
    } catch (e) {
      LogUtil.d('发送消息失败: $e');
      reseveMessage(AiMessageState.end, '');
      rethrow;
    }
  }

  /// 全程走 Responses API stream；content 边收边展示，流结束后处理 function_call。
  Future<void> _runStreamLoop() async {
    var isFirstRound = true;

    while (true) {
      final round = await _streamOneRound(startMessage: isFirstRound);
      isFirstRound = false;

      if (round.functionCalls.isEmpty) {
        if (round.content.isNotEmpty) {
          _inputItems.add(MessageItem.assistantText(round.content));
        }
        reseveMessage(AiMessageState.end, '');
        return;
      }

      await _handleFunctionCalls(round.functionCalls, content: round.content);
    }
  }

  Future<({String content, List<FunctionCallOutputItemResponse> functionCalls})> _streamOneRound({
    required bool startMessage,
  }) async {
    final accumulator = ResponseStreamAccumulator();
    final completer = Completer<void>();

    if (startMessage) reseveMessage(AiMessageState.start, '');

    final request = CreateResponseRequest(
      model: model,
      input: ResponseInput.items(List<Item>.from(_inputItems)),
      tools: _toolManager.getResponseToolDefinitions(),
    );

    currentSubscription = _client.responses
        .createStream(request)
        .listen(
          (event) {
            LogUtil.d('Stream 事件: ${event.toJson()}');
            accumulator.add(event);
            _emitStreamDelta(event);
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

    final response = accumulator.response;
    final content = accumulator.text.isNotEmpty ? accumulator.text : (response?.outputText ?? '');
    final functionCalls = response?.functionCalls ?? const [];
    return (content: content, functionCalls: functionCalls);
  }

  void _emitStreamDelta(ResponseStreamEvent event) {
    switch (event) {
      case OutputTextDeltaEvent(:final delta):
        if (delta.isNotEmpty) reseveMessage(AiMessageState.streaming, delta);
      case ReasoningTextDeltaEvent(:final delta):
      case ReasoningSummaryTextDeltaEvent(:final delta):
        if (delta.isNotEmpty) {
          reseveMessage(AiMessageState.streaming, '', reasoningContent: delta);
        }
      default:
        break;
    }
  }

  Future<void> _handleFunctionCalls(
    List<FunctionCallOutputItemResponse> functionCalls, {
    required String content,
  }) async {
    LogUtil.d('工具调用: ${functionCalls.map((t) => t.name).toList()}');

    if (content.isNotEmpty) {
      _inputItems.add(MessageItem.assistantText(content));
    }

    for (final call in functionCalls) {
      _inputItems.add(FunctionCallItem(id: call.id, callId: call.callId, name: call.name, arguments: call.arguments));

      final toolResult = await _toolManager.executeTool(call.name, call.arguments);
      LogUtil.d('工具 ${call.name} 结果: $toolResult');

      _inputItems.add(FunctionCallOutputItem.string(callId: call.callId, output: toolResult));
    }
  }

  @override
  Future<void> dispose() async {
    _client.close();
    await super.dispose();
  }
}
