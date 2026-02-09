import 'package:chat_ai/common/common.dart';
import 'package:flutter/cupertino.dart';

class CommonTextField extends StatefulWidget {
  final ValueChanged<String>? onSubmit;
  final ValueChanged<bool>? hasFocus;
  final String? placeholder;
  const CommonTextField({this.onSubmit, this.hasFocus, this.placeholder, super.key});

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
      decoration: BoxDecoration(color: Colors.transparent),
      controller: controller,
      focusNode: focusNode,
      placeholder: widget.placeholder,
      style: TextStyleTheme.regular16.copyWith(color: context.appTheme.textPrimary),
      maxLines: 10,
      minLines: 1,
      textInputAction: TextInputAction.send,
      onSubmitted: (value) {
        widget.onSubmit?.call(value);
        controller.clear();
      },
    );
  }
}
