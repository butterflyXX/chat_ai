import 'package:openai_dart/openai_dart.dart';

enum ToolName {
  takePhoto('take_photo'),
  getLocation('get_location');

  final String value;
  const ToolName(this.value);
}

/// LLM 可调用工具的抽象接口
abstract class AiTool {
  String get name;

  ResponseTool get definition;

  /// 返回 JSON 字符串，作为 function_call_output 回传给模型
  Future<String> execute(String? argumentsJson);
}
