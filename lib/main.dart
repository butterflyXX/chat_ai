import 'package:chat_ai/common/theme/theme.dart';
import 'package:chat_ai/provider/locale_state/locale_state.dart';
import 'package:chat_ai/provider/theme_state/theme_state.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:chat_ai/common/common.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ServiceManager.registerServers();
  runApp(AiProvider.scope(const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      child: Consumer(
        builder: (context, ref, child) {
          return MaterialApp.router(
            title: 'Flutter Demo',
            theme: lightTheme,
            darkTheme: darkTheme,
            localizationsDelegates: const [
              S.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: S.delegate.supportedLocales,
            locale: ref.watch(localeStateProvider).value,
            themeMode: ref.watch(themeStateProvider),
            routerConfig: router,
          );
        },
      ),
    );
  }
}
