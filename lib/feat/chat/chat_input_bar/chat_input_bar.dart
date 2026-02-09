import 'package:chat_ai/common/common.dart';
import 'package:chat_ai/common/widget/text_field/common_text_field.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class ChatBottomBar extends ConsumerStatefulWidget {
  final ValueChanged<String>? onSubmit;
  final ValueChanged<bool>? hasFocus;
  final bool aiing;
  final VoidCallback? onStop;

  const ChatBottomBar({this.onSubmit, this.hasFocus, required this.aiing, this.onStop, super.key});

  @override
  ConsumerState<ChatBottomBar> createState() => _ChatBottomBarState();
}

enum ChatBottomBarState {
  keyboard,
  speak;

  IconData get icon => switch (this) {
    ChatBottomBarState.keyboard => LucideIcons.keyboard,
    ChatBottomBarState.speak => LucideIcons.mic,
  };
}

class _ChatBottomBarState extends ConsumerState<ChatBottomBar> {
  ChatBottomBarState state = ChatBottomBarState.keyboard;
  bool isSpeaking = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.appTheme.backgroundColor,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.w),
            decoration: BoxDecoration(
              color: isSpeaking ? context.appTheme.highlightBlue : context.appTheme.fillsPrimary,
              borderRadius: BorderRadius.circular(16.w),
            ),
            child: Stack(
              children: [
                Opacity(opacity: isSpeaking ? 0 : 1, child: _buildKeyboardWidget()),
                IgnorePointer(
                  child: Opacity(opacity: isSpeaking ? 1 : 0, child: _buildSpeakingWidget()),
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).viewPadding.bottom),
        ],
      ),
    );
  }

  Widget _buildKeyboardWidget() {
    return Row(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            setState(() {
              state = switch (state) {
                ChatBottomBarState.keyboard => ChatBottomBarState.speak,
                ChatBottomBarState.speak => ChatBottomBarState.keyboard,
              };
            });
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Icon(state.icon),
          ),
        ),
        Expanded(
          child: switch (state) {
            ChatBottomBarState.keyboard => CommonTextField(
              onSubmit: widget.onSubmit,
              hasFocus: widget.hasFocus,
              placeholder: '发消息...',
            ),
            ChatBottomBarState.speak => GestureDetector(
              behavior: HitTestBehavior.opaque,
              onLongPress: _startRecord,
              onLongPressEnd: _stopRecord,
              child: Container(
                height: 32,
                alignment: Alignment.center,
                child: Text('按住 说话', style: TextStyleTheme.semibold18),
              ),
            ),
          },
        ),
        if (widget.aiing) _buildStopButton(),
      ],
    );
  }

  Widget _buildSpeakingWidget() {
    return Container(height: 32);
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

  Future<void> _startRecord() async {
    setState(() {
      isSpeaking = true;
    });
    await ServiceManager.getAsr.start();
  }

  Future<void> _stopRecord(LongPressEndDetails details) async {
    setState(() {
      isSpeaking = false;
    });
    final result = await ServiceManager.getAsr.stop();
    final str = result.map((e) => e.text).join('');
    widget.onSubmit?.call(str);
  }
}
