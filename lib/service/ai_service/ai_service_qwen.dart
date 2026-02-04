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
    messageBuffer.clear();
    _dio.options.headers['Authorization'] = 'Bearer $qwenAppKey';
    _dio.options.responseType = ResponseType.stream;
    final response = await _dio.post(
      'https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions',
      data: {
        'model': 'qwen-plus',
        "stream": true,
        'messages': [
          {'role': 'user', 'content': message},
        ],
      },
    );
    processQwenStream(response.data.stream);
  }

  void processQwenStream(Stream<List<int>> byteStream) {
    streamcontroller.add(AiMessageModel(state: AiMessageState.start, message: messageBuffer.toString()));
    // 1. 将字节流转换为字符串行流
    final lineStream = utf8.decoder
        .bind(byteStream) // 字节转字符串
        .transform(const LineSplitter()); // 按行切割

    lineStream.listen((line) {
      // 2. 过滤掉空行
      if (line.trim().isEmpty) return;

      // 3. 检查是否结束
      // if (line.startsWith("data: ")) {
      if (line.startsWith("data: [DONE]")) {
        streamcontroller.add(AiMessageModel(state: AiMessageState.end, message: messageBuffer.toString()));
        return;
      }

      // 4. 解析 data: 后面的 JSON
      if (line.startsWith("data: ")) {
        try {
          final jsonString = line.substring(6).trim(); // 去掉 "data: "
          final Map<String, dynamic> data = jsonDecode(jsonString);

          // 5. 提取增量内容 (Delta Content)
          final choices = data['choices'] as List;
          if (choices.isNotEmpty) {
            final delta = choices[0]['delta'];
            if (delta != null && delta['content'] != null) {
              String content = delta['content'];

              // 关键：将增量内容拼接到 UI
              messageBuffer.write(content);
              streamcontroller.add(AiMessageModel(state: AiMessageState.streaming, message: messageBuffer.toString()));
            }
          }
        } catch (e) {
          LogUtil.d("解析 JSON 出错: $e");
        }
      }
    });
  }
}
