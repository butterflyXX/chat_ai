import 'package:chat_ai/common/common.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'locale_state.g.dart';

enum LocaleType {
  zh(Locale('zh')),
  en(Locale('en'));

  final Locale value;

  const LocaleType(this.value);

  String get displayName => switch (this) {
    LocaleType.zh => S.current.localeZh,
    LocaleType.en => S.current.localeEn,
  };

  String get originalName => switch (this) {
    LocaleType.zh => '中文',
    LocaleType.en => 'English',
  };
}

@Riverpod(keepAlive: true)
class LocaleState extends _$LocaleState {
  @override
  LocaleType build() {
    final localeString = ServiceManager.getKv.get(KvKey.locale);
    return LocaleType.values.byName(localeString ?? 'zh');
  }

  void setLocale(LocaleType locale) {
    state = locale;
    ServiceManager.getKv.set(KvKey.locale, value: locale.name);
  }
}
