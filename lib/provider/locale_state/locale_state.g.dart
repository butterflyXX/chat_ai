// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locale_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LocaleState)
const localeStateProvider = LocaleStateProvider._();

final class LocaleStateProvider
    extends $NotifierProvider<LocaleState, LocaleType> {
  const LocaleStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localeStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localeStateHash();

  @$internal
  @override
  LocaleState create() => LocaleState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocaleType value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocaleType>(value),
    );
  }
}

String _$localeStateHash() => r'f413a045ab4f8e5a4e4d89614b003922576137f0';

abstract class _$LocaleState extends $Notifier<LocaleType> {
  LocaleType build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<LocaleType, LocaleType>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LocaleType, LocaleType>,
              LocaleType,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
