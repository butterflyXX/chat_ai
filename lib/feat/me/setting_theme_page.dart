import 'package:chat_ai/common/common.dart';
import 'package:chat_ai/common/widget/section_widget.dart';
import 'package:chat_ai/common/widget/select_item_widget.dart';
import 'package:chat_ai/provider/theme_state/theme_state.dart';

class SettingThemePage extends ConsumerStatefulWidget {
  const SettingThemePage({super.key});

  @override
  ConsumerState<SettingThemePage> createState() => _SettingThemePageState();
}

class _SettingThemePageState extends ConsumerState<SettingThemePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CAAppBar.commonAppbar(context, title: S.of(context).theme),
      body: SettingSectionWidget(children: ThemeMode.values.map((e) => _buildThemeItem(e)).toList()),
    );
  }

  Widget _buildThemeItem(ThemeMode mode) {
    return SettingChooseItemWidget(
      title: mode.displayName,
      value: ref.watch(themeStateProvider) == mode,
      onTap: () => ref.read(themeStateProvider.notifier).setThemeState(mode),
    );
  }
}
