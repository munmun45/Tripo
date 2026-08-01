import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';
import 'utils/device_compat.dart';

Future<void> main() async {
  await DeviceCompat.bootstrap();
  // Catch framework errors so one bad frame never freezes the process.
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
  };
  runApp(const TripoApp());
}

class TripoApp extends StatelessWidget {
  const TripoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tripo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      builder: DeviceCompat.appBuilder,
      // India-first locales — English + Hindi.
      supportedLocales: const [
        Locale('en'),
        Locale('hi'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supported) {
        if (locale == null) return const Locale('en');
        for (final s in supported) {
          if (s.languageCode == locale.languageCode) return s;
        }
        return const Locale('en');
      },
      home: const SplashScreen(),
    );
  }
}
