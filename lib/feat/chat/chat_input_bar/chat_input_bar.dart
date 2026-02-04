import 'package:chat_ai/common/common.dart';
import 'package:chat_ai/common/widget/text_field/common_text_field.dart';

class ChatBottomBar extends ConsumerStatefulWidget {
  final ValueChanged<String>? onSubmit;
  final ValueChanged<bool>? hasFocus;

  const ChatBottomBar({this.onSubmit, this.hasFocus, super.key});

  @override
  ConsumerState<ChatBottomBar> createState() => _ChatBottomBarState();
}

class _ChatBottomBarState extends ConsumerState<ChatBottomBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.appTheme.fillsSecondary,
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CommonTextField(onSubmit: widget.onSubmit, hasFocus: widget.hasFocus),
          SizedBox(height: MediaQuery.of(context).viewPadding.bottom),
        ],
      ),
    );
  }
}
