import 'package:chat_ai/feat/chat/chat_page.dart';
import 'package:chat_ai/feat/main/main_page.dart';
import 'package:chat_ai/feat/me/setting_locale_page.dart';
import 'package:chat_ai/feat/me/setting_theme_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

export 'package:go_router/go_router.dart';

part 'route.g.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  initialLocation: const MainRoute().location,
  navigatorKey: rootNavigatorKey,
  routes: $appRoutes,
  onException: (context, state, router) {},
  overridePlatformDefaultLocation: true,
  redirect: (context, state) {
    return null;
  },
);

@TypedGoRoute<MainRoute>(path: '/')
class MainRoute extends GoRouteData with $MainRoute {
  const MainRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const MainPage();
}

@TypedGoRoute<SettingThemeRoute>(path: '/setting/theme')
class SettingThemeRoute extends GoRouteData with $SettingThemeRoute {
  const SettingThemeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const SettingThemePage();
}

@TypedGoRoute<SettingLocaleRoute>(path: '/setting/locale')
class SettingLocaleRoute extends GoRouteData with $SettingLocaleRoute {
  const SettingLocaleRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const SettingLocalePage();
}

@TypedGoRoute<ChatRoute>(path: '/chat')
class ChatRoute extends GoRouteData with $ChatRoute {
  final int aiServiceType;
  const ChatRoute({required this.aiServiceType});

  @override
  Widget build(BuildContext context, GoRouterState state) => ChatPage(aiServiceType: aiServiceType);
}
