import 'package:logger/logger.dart';

class LogUtil {
  static final _logger = Logger(printer: PrettyPrinter(methodCount: 0, errorMethodCount: 0));

  /// Debug 日志
  static void d(dynamic obj) {
    _logger.d(obj.toString());
  }

  /// Info 日志
  static void i(dynamic obj) {
    _logger.i(obj.toString());
  }

  /// Warning 日志
  static void w(dynamic obj) {
    _logger.w(obj.toString());
  }

  /// Error 日志
  static void e(Object? mes, {StackTrace? stackTrace, Object? error}) {
    _logger.e(mes, error: error, stackTrace: stackTrace);
  }
}
