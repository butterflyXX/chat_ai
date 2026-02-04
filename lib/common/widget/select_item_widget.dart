import 'package:chat_ai/common/common.dart';

class SettingChooseItemWidget extends StatelessWidget {
  final String title;
  final bool value;
  final VoidCallback onTap;
  const SettingChooseItemWidget({required this.title, required this.value, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 12.w, horizontal: 16.w),
        child: Row(
          children: [
            Text(title, style: TextStyleTheme.medium14.copyWith(color: context.appTheme.textPrimary)),
            const Spacer(),
            value ? Icon(Icons.check, size: 16.w) : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}

class SettingSelectItemWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  const SettingSelectItemWidget({required this.title, this.subtitle, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Text(title, style: TextStyleTheme.medium14.copyWith(color: context.appTheme.textPrimary)),
                  const Spacer(),
                  if (subtitle != null)
                    Text(subtitle!, style: TextStyleTheme.regular14.copyWith(color: context.appTheme.textSecondary)),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            if (onTap != null) Icon(Icons.arrow_forward_ios, size: 12.w, color: context.appTheme.textPrimary),
          ],
        ),
      ),
    );
  }
}
