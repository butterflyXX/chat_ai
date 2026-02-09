import 'dart:async';
import 'dart:typed_data';

import 'package:chat_ai/common/common.dart';

abstract class RecordServiceBase {
  final List<ValueChanged<Uint8List>> _listeners = [];
  final _controller = StreamController<Uint8List>.broadcast();
  Stream<Uint8List> get audioStream => _controller.stream;
  VoidCallback listen(ValueChanged<Uint8List> listener) {
    _listeners.add(listener);
    return () => _removeListener(listener);
  }

  void _removeListener(ValueChanged<Uint8List> listener) {
    _listeners.remove(listener);
  }

  void add(Uint8List data) {
    _controller.sink.add(data);
    for (final listener in _listeners) {
      listener(data);
    }
  }

  Future<bool> start();
  Future<bool> stop();
}
