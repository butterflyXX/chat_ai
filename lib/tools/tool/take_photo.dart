import 'dart:convert';

import 'package:chat_ai/common/util/log_util.dart';
import 'package:chat_ai/tools/ai_tool.dart';
import 'package:image_picker/image_picker.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:permission_handler/permission_handler.dart';

class TakePhotoTool implements AiTool {
  final ImagePicker _picker = ImagePicker();

  @override
  String get name => ToolName.takePhoto.value;

  @override
  ResponseTool get definition => ResponseTool.function(
    name: name,
    description: '调起相机拍照。当用户需要拍照时使用此工具。',
    parameters: const {'type': 'object', 'properties': {}, 'required': []},
  );

  @override
  Future<String> execute(String? argumentsJson) async {
    final photoPath = await _pickPhoto();

    if (photoPath == null) {
      return jsonEncode({'success': false, 'message': '拍照失败或用户取消'});
    }

    return jsonEncode({
      'success': true,
      'photo_path': photoPath,
      'message': '拍照成功',
    });
  }

  Future<String?> _pickPhoto() async {
    try {
      if (!await _ensureCameraPermission()) {
        LogUtil.d('相机权限被拒绝');
        return null;
      }

      final image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (image == null) {
        LogUtil.d('用户取消了拍照');
        return null;
      }

      LogUtil.d('拍照成功: ${image.path}');
      return image.path;
    } catch (e) {
      LogUtil.d('拍照失败: $e');
      return null;
    }
  }

  Future<bool> _ensureCameraPermission() async {
    if (await Permission.camera.isGranted) return true;
    return (await Permission.camera.request()).isGranted;
  }
}
