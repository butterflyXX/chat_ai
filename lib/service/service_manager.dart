import 'package:chat_ai/service/kv/kv_service_base.dart';
import 'package:chat_ai/service/kv/sp_kv.dart';
import 'package:get_it/get_it.dart';

export 'package:chat_ai/service/kv/kv_service_base.dart';

final _serviceLocator = GetIt.instance;

class ServiceManager {
  static GetIt get get => _serviceLocator;

  static Future<void> registerServers() async {
    await _registerAsync<KvServiceBase>(() async => SpKvService.init());
  }

  static Future<void> _registerAsync<T extends Object>(FactoryFuncAsync<T> builder) async {
    _serviceLocator.registerSingletonAsync<T>(builder);
    await _serviceLocator.isReady<T>();
  }

  // static void _register<T extends Object>(T instance) {
  //   _serviceLocator.registerSingleton<T>(instance);
  // }

  static KvServiceBase get getKv => _serviceLocator.get<KvServiceBase>();
}
