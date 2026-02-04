import 'package:chat_ai/common/common.dart';
import 'package:chat_ai/common/widget/section_widget.dart';
import 'package:chat_ai/common/widget/select_item_widget.dart';
import 'package:chat_ai/provider/locale_state/locale_state.dart';

class SettingLocalePage extends ConsumerStatefulWidget {
  const SettingLocalePage({super.key});

  @override
  ConsumerState<SettingLocalePage> createState() => _SettingLocalePageState();
}

class _SettingLocalePageState extends ConsumerState<SettingLocalePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CAAppBar.commonAppbar(context, title: S.of(context).locale),
      body: SettingSectionWidget(children: LocaleType.values.map((e) => _buildLocaleItem(e)).toList()),
    );
  }

  Widget _buildLocaleItem(LocaleType locale) {
    return SettingChooseItemWidget(
      title: locale.originalName,
      value: ref.watch(localeStateProvider) == locale,
      onTap: () => ref.read(localeStateProvider.notifier).setLocale(locale),
    );
  }
}
