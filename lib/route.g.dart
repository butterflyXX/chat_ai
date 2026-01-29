// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
  $mainRoute,
  $settingThemeRoute,
  $settingLocaleRoute,
];

RouteBase get $mainRoute =>
    GoRouteData.$route(path: '/', factory: $MainRoute._fromState);

mixin $MainRoute on GoRouteData {
  static MainRoute _fromState(GoRouterState state) => const MainRoute();

  @override
  String get location => GoRouteData.$location('/');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $settingThemeRoute => GoRouteData.$route(
  path: '/setting/theme',
  factory: $SettingThemeRoute._fromState,
);

mixin $SettingThemeRoute on GoRouteData {
  static SettingThemeRoute _fromState(GoRouterState state) =>
      const SettingThemeRoute();

  @override
  String get location => GoRouteData.$location('/setting/theme');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $settingLocaleRoute => GoRouteData.$route(
  path: '/setting/locale',
  factory: $SettingLocaleRoute._fromState,
);

mixin $SettingLocaleRoute on GoRouteData {
  static SettingLocaleRoute _fromState(GoRouterState state) =>
      const SettingLocaleRoute();

  @override
  String get location => GoRouteData.$location('/setting/locale');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}
