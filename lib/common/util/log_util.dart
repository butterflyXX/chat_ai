import 'package:logger/logger.dart';
import 'dart:developer' as developer;

class _DeveloperConsoleOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    for (var line in event.lines) {
      developer.log(line);
    }
  }
}

class LogUtil {
  static final _logger = Logger(
    printer: PrettyPrinter(methodCount: 0, errorMethodCount: 0),
    output: _DeveloperConsoleOutput(),
  );

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
