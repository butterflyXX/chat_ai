import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

abstract class RecordServiceBase {
  final _controller = StreamController<Uint8List>.broadcast();
  Stream<Uint8List> get audioStream => _controller.stream;
  final _volumeController = StreamController<double>.broadcast();
  Stream<double> get volumeStream => _volumeController.stream;

  void add(Uint8List data) {
    _volumeController.sink.add(_calculateVolume(data));
    _controller.sink.add(data);
  }

  Future<bool> start();
  Future<bool> stop();

  double _calculateVolume(Uint8List pcmData) {
    if (pcmData.isEmpty) return -60.0;
    // 1. 将 List<int> 转为 Uint8List
    Uint8List bytes = Uint8List.fromList(pcmData);

    // 2. 使用 ByteData 解析
    ByteData byteData = bytes.buffer.asByteData();

    List<int> int16Samples = [];
    for (int i = 0; i < bytes.length; i += 2) {
      // Endian.little 表示小端序
      int sample = byteData.getInt16(i, Endian.little);
      int16Samples.add(sample);
    }

    // 计算 RMS（均方根）值
    double sumSquares = 0.0;
    for (final sample in int16Samples) {
      // 归一化到 [-1.0, 1.0] 范围
      final normalized = sample / 32768.0;
      sumSquares += normalized * normalized;
    }

    final rms = sqrt(sumSquares / int16Samples.length);

    // 转换为分贝（dB）
    // 使用公式: dB = 20 * log10(rms)
    // 避免 log(0) 的情况，设置最小值为 0.0001
    // log10(x) = log(x) / log(10)
    const ln10 = 2.302585092994046; // ln(10)
    final rmsValue = max(rms, 0.0001);
    final db = 20 * (log(rmsValue) / ln10);
    return db;
  }
}
