import 'dart:async';
import 'dart:convert';
import 'package:chat_ai/app_key.dart';
import 'package:chat_ai/common/util/log_util.dart';
import 'package:chat_ai/service/ai_service/ai_service_base.dart';
import 'package:http/http.dart' as http;
import 'package:langchain_core/chat_models.dart';
import 'package:langchain_core/prompts.dart';
import 'package:langchain_openai/langchain_openai.dart';

export 'package:chat_ai/service/ai_service/ai_service_base.dart';

class ChatAiServiceAgnes extends AiServiceBase {
  final _reasoningController = StreamController<String>.broadcast();
  late final _ReasoningExtractorClient _httpClient;
  late final ChatOpenAI _chat;

  ChatAiServiceAgnes() {
    _httpClient = _ReasoningExtractorClient(http.Client(), _reasoningController);
    _chat = ChatOpenAI(
      apiKey: agnesAppKey,
      baseUrl: 'https://apihub.agnes-ai.com/v1',
      client: _httpClient,
      defaultOptions: const ChatOpenAIOptions(model: 'agnes-2.0-flash'),
    );
  }

  @override
  Future<void> sendMessage(String message) async {
    await super.sendMessage(message);
    await currentSubscription?.cancel();
    currentSubscription = null;

    try {
      // 构建 LangChain 消息列表（AI 历史消息只传 content，不传 reasoningContent）
      final messages = historyMessages.map<ChatMessage>((m) {
        return m.role == AiMessageRole.user
            ? HumanChatMessage(content: ChatMessageContent.text(m.message))
            : AIChatMessage(content: m.message);
      }).toList();

      reseveMessage(AiMessageState.start, '');

      // 并行订阅 reasoning_content 流
      String pendingReasoning = '';
      final reasoningSub = _reasoningController.stream.listen((r) {
        pendingReasoning += r;
      });

      final chatStream = _chat.stream(PromptValue.chat(messages));

      currentSubscription = chatStream.listen(
        (result) {
          final content = result.output.content;
          final reasoning = pendingReasoning;
          pendingReasoning = '';
          if (content.isNotEmpty || reasoning.isNotEmpty) {
            reseveMessage(AiMessageState.streaming, content, reasoningContent: reasoning);
          }
        },
        onError: (e) {
          LogUtil.d('Stream 错误: $e');
          reseveMessage(AiMessageState.end, '');
        },
        onDone: () {
          LogUtil.d('Stream 完成');
          reseveMessage(AiMessageState.end, '');
          currentSubscription = null;
          reasoningSub.cancel();
        },
        cancelOnError: false,
      );
    } catch (e) {
      LogUtil.d('发送消息失败: $e');
      reseveMessage(AiMessageState.end, '');
      rethrow;
    }
  }

  @override
  Future<void> dispose() async {
    _chat.close();
    await _reasoningController.close();
    await super.dispose();
  }
}

/// 自定义 http.Client 包装器，拦截 SSE 流以提取 reasoning_content 字段。
/// langchain_openai 不解析该非标准字段，通过此包装器在响应流中旁路提取后广播。
class _ReasoningExtractorClient extends http.BaseClient {
  final http.Client _inner;
  final StreamController<String> _reasoningController;

  _ReasoningExtractorClient(this._inner, this._reasoningController);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = await _inner.send(request);

    final transformedStream = response.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .map((line) {
          _extractReasoningContent(line);
          return line;
        })
        .transform(const _StringToUint8ListTransformer());

    return http.StreamedResponse(
      transformedStream,
      response.statusCode,
      contentLength: response.contentLength,
      request: response.request,
      headers: response.headers,
      isRedirect: response.isRedirect,
      persistentConnection: response.persistentConnection,
      reasonPhrase: response.reasonPhrase,
    );
  }

  void _extractReasoningContent(String line) {
    final trimmed = line.trim();
    if (trimmed.length <= 6) return;
    if (!trimmed.startsWith('data: ')) return;
    if (trimmed.startsWith('data: [DONE]')) return;
    try {
      final decoded = jsonDecode(trimmed.substring(6)) as Map<String, dynamic>;
      final choices = decoded['choices'] as List?;
      if (choices == null || choices.isEmpty) return;
      final delta = (choices[0] as Map<String, dynamic>)['delta'] as Map<String, dynamic>?;
      final reasoning = delta?['reasoning_content'] as String?;
      if (reasoning != null && reasoning.isNotEmpty) {
        _reasoningController.add(reasoning);
      }
    } catch (_) {}
  }

  @override
  void close() => _inner.close();
}

/// 将 String 流重新编码为 UTF-8 字节流，恢复供 langchain_openai 底层解析。
class _StringToUint8ListTransformer extends StreamTransformerBase<String, List<int>> {
  const _StringToUint8ListTransformer();

  @override
  Stream<List<int>> bind(Stream<String> stream) {
    return stream.map((line) => utf8.encode('$line\n'));
  }
}
