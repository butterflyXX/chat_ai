import 'package:chat_ai/service/kv/kv_service_base.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SpKvService extends KvServiceBase {
  final SharedPreferences sp;
  SpKvService(this.sp);

  static Future<SpKvService> init() async {
    final sp = await SharedPreferences.getInstance();
    return SpKvService(sp);
  }

  @override
  T? get<T>(KvKey<T> kvKey) {
    try {
      return sp.get(kvKey.name) as T?;
    } catch (_) {}
    return null;
  }

  @override
  Future<bool> set<T>(KvKey<T> kvKey, {T? value}) {
    if (value == null) {
      return remove(kvKey);
    }
    return switch (value) {
      String _ => sp.setString(kvKey.name, value),
      bool _ => sp.setBool(kvKey.name, value),
      int _ => sp.setInt(kvKey.name, value),
      double _ => sp.setDouble(kvKey.name, value),
      List<String> _ => sp.setStringList(kvKey.name, value),
      _ => throw ArgumentError("Unsupported type: ${value.runtimeType}"),
    };
  }

  @override
  Future<bool> remove(KvKey kvKey) async {
    try {
      return sp.remove(kvKey.name);
    } catch (_) {
      return false;
    }
  }
}
