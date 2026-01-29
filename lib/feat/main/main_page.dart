import 'package:chat_ai/common/common.dart';
import 'package:chat_ai/feat/enum/main_navigator_bar_item_type.dart';

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  final _tabs = [NavigatorBarItemType.home, NavigatorBarItemType.me];
  NavigatorBarItemType _currentTab = NavigatorBarItemType.home;

  final PageController _pageController = PageController(keepPage: true);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        itemBuilder: (context, index) => _tabs[index].widget(),
        itemCount: _tabs.length,
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: context.appTheme.textPrimary,
        unselectedItemColor: context.appTheme.textTertiary,
        backgroundColor: context.appTheme.fillsPrimary,
        unselectedFontSize: 10.sp,
        selectedFontSize: 10.sp,
        iconSize: 22.w,
        type: BottomNavigationBarType.fixed,
        items: NavigatorBarItemType.values
            .map((e) => BottomNavigationBarItem(icon: e.icon(context), label: e.title(context)))
            .toList(),
        currentIndex: _tabs.indexOf(_currentTab),
        onTap: _switchTab,
      ),
    );
  }

  void _switchTab(int index) {
    _pageController.jumpToPage(index);
    setState(() {
      _currentTab = _tabs[index];
    });
  }
}
