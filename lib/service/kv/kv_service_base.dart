enum KvKey<T> {
  themeState<String>(false),
  locale<String>(false);

  final bool value;

  const KvKey(this.value);
}

abstract class KvServiceBase {
  T? get<T>(KvKey<T> kvKey);

  Future<bool> set<T>(KvKey<T> kvKey, {T? value});

  Future<bool> remove(KvKey kvKey);
}
