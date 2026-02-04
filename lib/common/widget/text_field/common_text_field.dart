import 'package:chat_ai/common/common.dart';
import 'package:flutter/cupertino.dart';

class CommonTextField extends StatefulWidget {
  final ValueChanged<String>? onSubmit;
  final ValueChanged<bool>? hasFocus;
  const CommonTextField({this.onSubmit, this.hasFocus, super.key});

  @override
  State<CommonTextField> createState() => _CommonTextFieldState();
}

class _CommonTextFieldState extends State<CommonTextField> {
  TextEditingController controller = TextEditingController();

  final focusNode = FocusNode();

  @override
  void initState() {
    focusNode.addListener(_listener);
    super.initState();
  }

  void _listener() {
    widget.hasFocus?.call(focusNode.hasFocus);
  }

  @override
  void dispose() {
    focusNode.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTextField(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: context.appTheme.fillsPrimary),
      controller: controller,
      focusNode: focusNode,
      maxLines: 10,
      minLines: 1,
      textInputAction: TextInputAction.send,
      onSubmitted: (value) {
        widget.onSubmit?.call(value);
        controller.clear();
        focusNode.requestFocus();
      },
    );
  }
}
