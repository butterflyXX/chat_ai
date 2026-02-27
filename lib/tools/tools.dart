enum ToolName {
  takePhoto('take_photo');

  final String value;
  const ToolName(this.value);
}

final tools = [
  {'name': ToolName.takePhoto.value, 'description': '拍照'},
];
