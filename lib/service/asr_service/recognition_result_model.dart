class RecognitionResult {
  final String text;
  final bool isFinal; // 0-确定性结果；1-中间结果
  final bool isEnd;

  RecognitionResult(this.text, this.isFinal, this.isEnd);
}
