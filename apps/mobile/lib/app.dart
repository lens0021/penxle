import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glyph/routers/app.dart';
import 'package:glyph/routers/observer.dart';
import 'package:glyph/screens/splash.dart';
import 'package:glyph/themes/colors.dart';

class App extends ConsumerWidget {
  App({super.key});

  final _router = AppRouter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const defaultTextStyle = TextStyle(
      color: BrandColors.gray_900,
      height: 1.44,
      letterSpacing: -0.04,
    );

    return MaterialApp.router(
      routerConfig: _router.config(
        placeholder: (context) => const SplashScreen(),
        navigatorObservers: () => [AppRouterObserver()],
      ),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'SUIT',
        scaffoldBackgroundColor: Colors.white,
        dividerTheme: const DividerThemeData(
          color: BrandColors.gray_100,
          space: 0,
        ),
        textTheme: const TextTheme(
          bodySmall: defaultTextStyle,
          bodyMedium: defaultTextStyle,
          bodyLarge: defaultTextStyle,
          displaySmall: defaultTextStyle,
          displayMedium: defaultTextStyle,
          displayLarge: defaultTextStyle,
          headlineSmall: defaultTextStyle,
          headlineMedium: defaultTextStyle,
          headlineLarge: defaultTextStyle,
          labelSmall: defaultTextStyle,
          labelMedium: defaultTextStyle,
          labelLarge: defaultTextStyle,
          titleSmall: defaultTextStyle,
          titleMedium: defaultTextStyle,
          titleLarge: defaultTextStyle,
        ),
      ),
    );
  }
}
