import 'package:chat_ai/common/common.dart';
import 'package:chat_ai/common/widget/section_widget.dart';
import 'package:chat_ai/provider/locale_state/locale_state.dart';
import 'package:chat_ai/provider/theme_state/theme_state.dart';

class MePage extends ConsumerStatefulWidget {
  const MePage({super.key});

  @override
  ConsumerState<MePage> createState() => _MePageState();
}

class _MePageState extends ConsumerState<MePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CAAppBar.commonAppbar(context, title: S.of(context).me),
      body: ListView(
        children: [
          SettingSectionWidget(
            title: S.of(context).general,
            children: [
              _buildItem(
                S.of(context).theme,
                subtitle: ref.watch(themeStateProvider).displayName,
                onTap: () {
                  context.push(SettingThemeRoute().location);
                },
              ),
              _buildItem(
                S.of(context).locale,
                subtitle: ref.watch(localeStateProvider).displayName,
                onTap: () {
                  context.push(SettingLocaleRoute().location);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItem(String title, {String? subtitle, VoidCallback? onTap}) {
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
                    Text(subtitle, style: TextStyleTheme.regular14.copyWith(color: context.appTheme.textSecondary)),
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
