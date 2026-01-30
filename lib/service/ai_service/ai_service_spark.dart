import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:chat_ai/common/util/log_util.dart';
import 'package:chat_ai/service/ai_service/ai_service_base.dart';
import 'package:crypto/crypto.dart';
import 'package:web_socket_channel/io.dart';

export 'package:chat_ai/service/ai_service/ai_service_base.dart';

class ChatAiService extends AiServiceBase {
  final wsParam = SparkWsParam();

  @override
  Future<void> sendMessage(String message) async {
    messageBuffer.clear();
    final channel = IOWebSocketChannel.connect(wsParam.createUrl(), pingInterval: const Duration(seconds: 5));

    // 连接建立后发送请求
    channel.sink.add(jsonEncode(_genParams(appId: wsParam.appId, query: message, domain: wsParam.domain)));

    // 监听消息
    channel.stream.listen(
      (message) {
        final data = jsonDecode(message);
        LogUtil.d('data: $data');
        final code = data['header']['code'];
        if (code != 0) {
          LogUtil.d('请求错误: $code, $data');
          channel.sink.close();
        } else {
          final choices = data['payload']['choices'];
          final status = AiMessageState.fromValue(choices['status']);
          final content = choices['text'][0]['content'];
          messageBuffer.write(content);
          streamcontroller.add(AiMessageModel(state: status, message: messageBuffer.toString()));

          if (status == AiMessageState.end) {
            LogUtil.d('\n#### 关闭会话');
            channel.sink.close();
          }
        }
      },
      onError: (err) {
        LogUtil.d('WebSocket 错误: $err');
      },
      onDone: () {
        LogUtil.d('连接已关闭');
      },
    );
  }

  Map<String, dynamic> _genParams({required String appId, required String query, required String domain}) {
    return {
      "header": {"app_id": appId, "uid": "1234"},
      "parameter": {
        "chat": {"domain": domain, "temperature": 0.5, "max_tokens": 4096, "auditing": "default"},
      },
      "payload": {
        "message": {
          "text": [
            {"role": "user", "content": query},
          ],
        },
      },
    };
  }
}

class SparkWsParam {
  final String appId = '28991844';
  final String apiKey = '2cfb41b426628d73ba16640d50279bc9';
  final String apiSecret = 'ZTY2OThlYTc5NzU5NmI1MDQ1ZGFhOTkz';
  final String gptUrl = 'wss://spark-api.xf-yun.com/v1.1/chat';
  final String domain = 'lite';

  /// 生成带鉴权参数的完整 URL
  String createUrl() {
    final uri = Uri.parse(gptUrl);
    final host = uri.host;
    final path = uri.path;

    // 生成 RFC1123 时间戳
    final date = HttpDate.format(DateTime.now().toUtc());

    // 拼接签名字符串
    final signatureOrigin =
        'host: $host\n'
        'date: $date\n'
        'GET $path HTTP/1.1';

    // HMAC-SHA256 加密
    final hmacSha256 = Hmac(sha256, utf8.encode(apiSecret));
    final digest = hmacSha256.convert(utf8.encode(signatureOrigin));
    final signatureBase64 = base64Encode(digest.bytes);

    // authorization
    final authorizationOrigin =
        'api_key="$apiKey", algorithm="hmac-sha256", headers="host date request-line", signature="$signatureBase64"';
    final authorization = base64Encode(utf8.encode(authorizationOrigin));

    // 组合 URL 参数，直接使用 Uri.replace 防止出现重复 ? 或异常端口
    final queryParams = {'authorization': authorization, 'date': date, 'host': host};

    final fullUri = uri.replace(queryParameters: queryParams);
    return fullUri.toString();
  }
}
