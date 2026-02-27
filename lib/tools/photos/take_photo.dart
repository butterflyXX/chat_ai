import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:chat_ai/common/util/log_util.dart';

/// 拍照工具
class TakePhotoTool {
  final ImagePicker _picker = ImagePicker();

  /// 执行拍照
  /// 返回照片文件的路径，失败返回 null
  Future<String?> execute() async {
    try {
      // 检查相机权限
      final isGranted = await checkPermission();
      if (!isGranted) {
        final isGranted = await requestPermission();
        if (!isGranted) {
          LogUtil.d('相机权限被拒绝');
          return null;
        }
      }

      // 调起相机拍照
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85, // 图片质量 0-100
        preferredCameraDevice: CameraDevice.rear, // 使用后置摄像头
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

  /// 检查相机权限
  Future<bool> checkPermission() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  /// 请求相机权限
  Future<bool> requestPermission() async {
    final result = await Permission.camera.request();
    return result.isGranted;
  }
}
