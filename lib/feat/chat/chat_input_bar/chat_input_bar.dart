import 'package:chat_ai/common/common.dart';
import 'package:chat_ai/common/widget/text_field/common_text_field.dart';

class ChatBottomBar extends ConsumerStatefulWidget {
  final ValueChanged<String>? onSubmit;
  final ValueChanged<bool>? hasFocus;
  final bool aiing;
  final VoidCallback? onStop;

  const ChatBottomBar({this.onSubmit, this.hasFocus, required this.aiing, this.onStop, super.key});

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
          Row(
            children: [
              Expanded(
                child: CommonTextField(onSubmit: widget.onSubmit, hasFocus: widget.hasFocus),
              ),
              if (widget.aiing) _buildStopButton(),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).viewPadding.bottom),
        ],
      ),
    );
  }

  Widget _buildStopButton() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onStop,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Icon(Icons.stop_circle_outlined, size: 24.w, color: context.appTheme.textPrimary),
      ),
    );
  }
}
