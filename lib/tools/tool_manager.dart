import 'dart:convert';

import 'package:chat_ai/common/util/log_util.dart';
import 'package:chat_ai/tools/ai_tool.dart';
import 'package:chat_ai/tools/tool/get_location.dart';
import 'package:chat_ai/tools/tool/take_photo.dart';
import 'package:openai_dart/openai_dart.dart';

/// 工具注册与调度：向 LLM 暴露定义，并执行 function call
class ToolManager {
  final Map<String, AiTool> _tools = {
    ToolName.takePhoto.value: TakePhotoTool(),
    ToolName.getLocation.value: GetLocationTool(),
  };

  List<ResponseTool> getResponseToolDefinitions() => _tools.values.map((tool) => tool.definition).toList();

  Future<String> executeTool(String toolName, String? arguments) async {
    LogUtil.d('执行工具: $toolName, 参数: $arguments');

    final tool = _tools[toolName];
    if (tool == null) {
      return jsonEncode({'error': '未知的工具: $toolName'});
    }

    try {
      return await tool.execute(arguments);
    } catch (e) {
      LogUtil.d('工具执行失败: $e');
      return jsonEncode({'error': '工具执行失败: $e'});
    }
  }
}
