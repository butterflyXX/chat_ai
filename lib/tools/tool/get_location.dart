import 'dart:convert';

import 'package:chat_ai/common/util/log_util.dart';
import 'package:chat_ai/tools/ai_tool.dart';
import 'package:geolocator/geolocator.dart';
import 'package:openai_dart/openai_dart.dart';

class GetLocationTool implements AiTool {
  @override
  String get name => ToolName.getLocation.value;

  @override
  ResponseTool get definition => ResponseTool.function(
    name: name,
    description: '获取用户当前地理位置（经纬度）。当用户询问位置、天气、附近信息等时使用此工具。',
    parameters: const {'type': 'object', 'properties': {}, 'required': []},
  );

  @override
  Future<String> execute(String? argumentsJson) async {
    final position = await _getCurrentPosition();
    if (position == null) {
      return jsonEncode({'success': false, 'message': '定位失败或权限被拒绝'});
    }

    return jsonEncode({
      'success': true,
      'latitude': position.latitude,
      'longitude': position.longitude,
      'accuracy': position.accuracy,
      'message': '定位成功',
    });
  }

  Future<Position?> _getCurrentPosition() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        LogUtil.d('定位服务未开启');
        return null;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        LogUtil.d('定位权限被拒绝');
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      LogUtil.d('定位成功: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      LogUtil.d('定位失败: $e');
      return null;
    }
  }
}
