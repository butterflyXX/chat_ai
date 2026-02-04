import 'package:chat_ai/common/common.dart';

class SettingSectionWidget extends StatelessWidget {
  const SettingSectionWidget({super.key, this.title, required this.children});
  final String? title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(title!, style: TextStyleTheme.medium14.copyWith(color: context.appTheme.textPrimary)),
            SizedBox(height: 12.w),
          ],
          Container(
            padding: EdgeInsets.symmetric(vertical: 4.w),
            decoration: BoxDecoration(color: context.appTheme.fillsPrimary, borderRadius: BorderRadius.circular(16.w)),
            child: ListView.separated(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) => children[index],
              separatorBuilder: (context, index) => Container(
                height: 1.px,
                color: context.appTheme.separatorsSecondary,
                margin: EdgeInsets.only(left: 16.w),
              ),
              itemCount: children.length,
            ),
          ),
        ],
      ),
    );
  }
}
