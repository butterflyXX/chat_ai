import 'dart:async';
import 'dart:convert';
import 'package:chat_ai/app_key.dart';
import 'package:chat_ai/common/util/log_util.dart';
import 'package:chat_ai/service/ai_service/ai_service_base.dart';
import 'package:dio/dio.dart';

export 'package:chat_ai/service/ai_service/ai_service_base.dart';

class ChatAiServiceQwen extends AiServiceBase {
  final _dio = Dio();

  @override
  Future<void> sendMessage(String message) async {
    await super.sendMessage(message);

    await currentSubscription?.cancel();
    currentSubscription = null;

    try {
      _dio.options.headers['Authorization'] = 'Bearer $qwenAppKey';
      _dio.options.responseType = ResponseType.stream;
      final response = await _dio.post(
        'https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions',
        data: {
          'model': 'qwen3.7-plus',
          'stream': true,
          'messages': [
            ...historyMessages.map((e) => {'role': e.role.name, 'content': e.message}),
          ],
        },
      );

      if (response.data?.stream != null) {
        _processQwenStream(response.data!.stream);
      } else {
        LogUtil.d("响应数据为空");
        reseveMessage(AiMessageState.end, '');
      }
    } catch (e) {
      LogUtil.d("发送消息失败: $e");
      reseveMessage(AiMessageState.end, '');
      rethrow;
    }
  }

  void _processQwenStream(Stream<List<int>> byteStream) {
    reseveMessage(AiMessageState.start, '');

    final lineStream = utf8.decoder.bind(byteStream).transform(const LineSplitter());

    currentSubscription = lineStream.listen(
      (line) {
        try {
          _processLine(line);
        } catch (e) {
          LogUtil.d("处理行数据出错: $e, line: $line");
        }
      },
      onError: (error) {
        LogUtil.d("Stream 错误: $error");
        reseveMessage(AiMessageState.end, '');
      },
      onDone: () {
        LogUtil.d("Stream 完成");
        reseveMessage(AiMessageState.end, '');
        currentSubscription = null;
      },
      cancelOnError: false,
    );
  }

  void _processLine(String line) {
    final trimmedLine = line.trim();
    if (trimmedLine.isEmpty) return;

    // [DONE] 标志由 onDone 统一处理，此处跳过，避免重复触发 end
    if (trimmedLine.startsWith('data: [DONE]')) return;
    if (!trimmedLine.startsWith('data: ') || trimmedLine.length <= 6) return;

    try {
      final jsonString = trimmedLine.substring(6).trim();
      if (jsonString.isEmpty) return;

      final decoded = jsonDecode(jsonString);
      if (decoded is! Map<String, dynamic>) return;

      final choices = decoded['choices'];
      // choices 为空列表时是末尾的 usage 统计块，直接跳过
      if (choices is! List || choices.isEmpty) return;

      final firstChoice = choices[0];
      if (firstChoice is! Map<String, dynamic>) return;

      final delta = firstChoice['delta'];
      if (delta is! Map<String, dynamic>) return;

      // 思考链内容（qwen3.7-plus 等推理模型专有字段）
      final reasoningContent = delta['reasoning_content'];
      if (reasoningContent is String && reasoningContent.isNotEmpty) {
        reseveMessage(AiMessageState.streaming, '', reasoningContent: reasoningContent);
      }

      // 正式回答内容
      final content = delta['content'];
      if (content is String && content.isNotEmpty) {
        reseveMessage(AiMessageState.streaming, content);
      }
    } catch (e) {
      LogUtil.d("解析 JSON 出错: $e, line: $trimmedLine");
    }
  }

  @override
  Future<void> dispose() async {
    await super.dispose();
  }
}
