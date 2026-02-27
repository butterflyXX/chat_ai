import 'dart:convert';
import 'package:chat_ai/common/util/log_util.dart';
import 'package:chat_ai/tools/photos/take_photo.dart';

enum ToolName {
  takePhoto('take_photo');

  final String value;
  const ToolName(this.value);
}

/// 工具管理器：处理 LLM 的 tool calls
class ToolManager {
  final TakePhotoTool _takePhotoTool = TakePhotoTool();

  /// 执行工具调用
  /// [toolName] 工具名称
  /// [arguments] 工具参数（JSON 字符串）
  /// 返回执行结果（JSON 字符串）
  Future<String> executeTool(String toolName, String? arguments) async {
    LogUtil.d('执行工具: $toolName, 参数: $arguments');

    try {
      if (toolName == 'take_photo') {
        return await _executeTakePhoto(arguments);
      } else {
        return jsonEncode({'error': '未知的工具: $toolName'});
      }
    } catch (e) {
      LogUtil.d('工具执行失败: $e');
      return jsonEncode({'error': '工具执行失败: $e'});
    }
  }

  /// 执行拍照工具
  Future<String> _executeTakePhoto(String? arguments) async {
    final photoPath = await _takePhotoTool.execute();

    if (photoPath == null) {
      return jsonEncode({'success': false, 'message': '拍照失败或用户取消'});
    }

    return jsonEncode({'success': true, 'photo_path': photoPath, 'message': '拍照成功'});
  }

  /// 获取所有可用工具的定义（用于发送给 LLM）
  List<Map<String, dynamic>> getToolDefinitions() {
    return [
      {
        'type': 'function',
        'function': {
          'name': ToolName.takePhoto.value,
          'description': '调起相机拍照。当用户需要拍照时使用此工具。',
          'parameters': {'type': 'object', 'properties': {}, 'required': []},
        },
      },
    ];
  }
}
