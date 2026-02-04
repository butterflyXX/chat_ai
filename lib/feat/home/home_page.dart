import 'package:chat_ai/common/common.dart';
import 'package:chat_ai/common/widget/section_widget.dart';
import 'package:chat_ai/common/widget/select_item_widget.dart';
import 'package:chat_ai/feat/chat/chat_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CAAppBar.commonAppbar(context, title: S.of(context).home),
      body: SettingSectionWidget(children: AiServiceType.values.map((e) => _buildAiServiceItem(e)).toList()),
    );
  }

  Widget _buildAiServiceItem(AiServiceType aiServiceType) {
    return SettingSelectItemWidget(
      title: aiServiceType.displayName(context),
      onTap: () => context.push(ChatRoute(aiServiceType: aiServiceType.value).location),
    );
  }
}
