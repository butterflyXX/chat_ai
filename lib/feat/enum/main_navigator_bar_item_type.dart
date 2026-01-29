import 'package:chat_ai/common/common.dart';
import 'package:chat_ai/feat/home/home_page.dart';
import 'package:chat_ai/feat/me/me_page.dart';

enum NavigatorBarItemType {
  home(0),
  me(1);

  final int value;
  const NavigatorBarItemType(this.value);

  String title(BuildContext context) => switch (this) {
    NavigatorBarItemType.home => S.of(context).home,
    NavigatorBarItemType.me => S.of(context).me,
  };

  Widget icon(BuildContext context) => switch (this) {
    NavigatorBarItemType.home => Icon(Icons.home),
    NavigatorBarItemType.me => Icon(Icons.person),
  };

  Widget widget() => switch (this) {
    NavigatorBarItemType.home => const CIKeepAliveWidget(child: HomePage()),
    NavigatorBarItemType.me => const CIKeepAliveWidget(child: MePage()),
  };
}
