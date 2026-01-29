import 'package:chat_ai/common/common.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_state.g.dart';

extension ThemeStateExtension on ThemeMode {
  String get displayName => switch (this) {
    ThemeMode.light => S.current.themeLight,
    ThemeMode.dark => S.current.themeDark,
    ThemeMode.system => S.current.themeSystem,
  };
}

@Riverpod(keepAlive: true)
class ThemeState extends _$ThemeState {
  @override
  ThemeMode build() {
    final themeStateString = ServiceManager.getKv.get(KvKey.themeState);
    return ThemeMode.values.byName(themeStateString ?? 'system');
  }

  void setThemeState(ThemeMode themeState) {
    state = themeState;
    ServiceManager.getKv.set(KvKey.themeState, value: themeState.name);
  }

  bool get isDark => state == ThemeMode.dark;
}
