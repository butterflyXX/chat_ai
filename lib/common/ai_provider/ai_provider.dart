import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AiProvider {
  static Widget scope(Widget child) {
    return ProviderScope(
      child: Builder(
        builder: (context) {
          _readProviderContext = context;
          return child;
        },
      ),
    );
  }

  static late BuildContext _readProviderContext;

  static T read<T>(Provider<T> provider) {
    return ProviderScope.containerOf(_readProviderContext).read(provider);
  }
}
