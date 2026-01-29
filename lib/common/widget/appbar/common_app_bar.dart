import 'package:chat_ai/common/common.dart';

class CAAppBar {
  static AppBar commonAppbar(
    BuildContext context, {
    String? title,
    Widget? textTitle,
    PreferredSizeWidget? bottom,
    double? elevation,
    List<Widget>? actions,
    Widget? leading,
    VoidCallback? onLeadingAction,
    bool isShowBack = true,
  }) {
    final canPop = ModalRoute.of(context)?.canPop ?? false;
    if (canPop && isShowBack) {
      leading ??= GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onLeadingAction ?? Navigator.of(context).maybePop,
        child: Center(
          child: SvgImage.asset(Assets.svgBackIcon, width: 24.w, height: 24.w, color: context.appTheme.textPrimary),
        ),
      );
    }

    return AppBar(
      elevation: elevation,
      centerTitle: true,
      title: textTitle ?? Text(title ?? "", style: TextStyleTheme.semibold16),
      leading: leading,
      leadingWidth: 60.w,
      actions: actions != null ? [...actions, SizedBox(width: 16.w)] : null,
      bottom: bottom,
    );
  }
}
