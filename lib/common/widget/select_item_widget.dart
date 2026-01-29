import 'package:chat_ai/common/common.dart';

class SettingSelectItemWidget extends StatelessWidget {
  final String title;
  final bool value;
  final VoidCallback onTap;
  const SettingSelectItemWidget({required this.title, required this.value, required this.onTap, super.key});

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
