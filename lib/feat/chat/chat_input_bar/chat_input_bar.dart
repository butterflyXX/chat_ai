import 'package:chat_ai/common/common.dart';
import 'package:chat_ai/common/widget/text_field/common_text_field.dart';
import 'package:flutter/services.dart';
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
  ChatBottomBarVolumeState volumeState = ChatBottomBarVolumeState.on;
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
              color: isSpeaking
                  ? volumeState == ChatBottomBarVolumeState.on
                        ? context.appTheme.highlightBlue
                        : context.appTheme.highlightRed
                  : context.appTheme.fillsPrimary,
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
              onLongPressEnd: (_) => _stopRecord(false),
              onLongPressCancel: () => _stopRecord(true),
              onLongPressMoveUpdate: _onLongPressMoveUpdate,
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
    return const _ChatBottomBarVolumeWidget();
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
    HapticFeedback.vibrate();
    setState(() {
      volumeState = ChatBottomBarVolumeState.on;
      isSpeaking = true;
    });
    await ServiceManager.getAsr.start();
  }

  Future<void> _stopRecord(bool isCancel) async {
    setState(() {
      isSpeaking = false;
    });
    final result = await ServiceManager.getAsr.stop();
    if (isCancel || volumeState == ChatBottomBarVolumeState.cancel) return;
    final str = result.map((e) => e.text).join('');
    if (result.isEmpty || str.isEmpty) {
      showToast(S.current.chatBarNoVoice);
      return;
    }
    widget.onSubmit?.call(str);
  }

  void _onLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    final renderObject = context.findRenderObject() as RenderBox;
    final offset = renderObject.globalToLocal(details.globalPosition);
    final newVolumeState = offset.dy > 0 && offset.dx > 0
        ? ChatBottomBarVolumeState.on
        : ChatBottomBarVolumeState.cancel;
    if (newVolumeState != volumeState) {
      HapticFeedback.vibrate();
      setState(() {
        volumeState = newVolumeState;
      });
    }
  }
}

enum ChatBottomBarVolumeState { on, cancel }

class _ChatBottomBarVolumeWidget extends StatefulWidget {
  const _ChatBottomBarVolumeWidget();
  @override
  State<_ChatBottomBarVolumeWidget> createState() => _ChatBottomBarVolumeWidgetState();
}

class _ChatBottomBarVolumeWidgetState extends State<_ChatBottomBarVolumeWidget> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: StreamBuilder<double>(
        stream: ServiceManager.getRecord.volumeStream,
        builder: (context, snapshot) {
          return getItem(getSmoothScale(snapshot.data ?? 0));
        },
      ),
    );
  }

  Widget getItem(double scale) {
    final double maxHeight = 22.0;

    final List<double> weights = [
      ...[0.01, 0.02, 0.05, 0.15, 0.2, 0.4, 0.7],
      ...[0.4, 0.2, 0.05],
      ...[0.15, 0.2, 0.4, 0.7, 1],
      ...[0.7, 0.4, 0.2, 0.15],
      ...[0.05, 0.2, 0.4],
      ...[0.7, 0.4, 0.2, 0.15, 0.05, 0.02, 0.01],
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: weights.map((w) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          margin: const EdgeInsets.symmetric(horizontal: 1),
          width: 3,
          height: (maxHeight * scale * w) + 2.0,
          decoration: BoxDecoration(color: ColorsTheme.textOndarkPrimary, borderRadius: BorderRadius.circular(2)),
        );
      }).toList(),
    );
  }

  double getSmoothScale(double db) {
    const double silenceThreshold = -42.0;
    const double maxDb = -15.0;

    double targetScale;

    if (db < silenceThreshold) {
      targetScale = 0.0;
    } else {
      targetScale = (db - silenceThreshold) / (maxDb - silenceThreshold);
    }

    targetScale = targetScale.clamp(0.0, 1.0);
    return targetScale;
  }
}
