import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'package:traccar_client/config/tasks_config.dart';
import 'package:traccar_client/geolocation_service.dart';
import 'package:traccar_client/quick_actions.dart';

import 'l10n/app_localizations.dart';
import 'main_screen.dart';
import 'preferences.dart';
import 'configuration_service.dart';

final messengerKey = GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (FlutterErrorDetails details) {
    developer.log(
      'Flutter error',
      error: details.exception,
      stackTrace: details.stack,
    );
  };
  await Preferences.init();
  await Preferences.migrate();
  await GeolocationService.init();
  await TasksConfig.load(); // Add this
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();
    _initLinks();
  }

  Future<void> _initLinks() async {
    final appLinks = AppLinks();
    final uri = await appLinks.getInitialLink();
    if (uri != null) {
      await ConfigurationService.applyUri(uri);
    }
    appLinks.uriLinkStream.listen((uri) async {
      await ConfigurationService.applyUri(uri);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: messengerKey,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0d9488), // Teal primary color
          brightness: Brightness.light,
          primary: const Color(0xFF0d9488),
          secondary: const Color(0xFF0d9488),
          surface: const Color(0xFFFFFBFE),
          error: const Color(0xFFBA1A1A),
        ),
        scaffoldBackgroundColor: const Color(
          0xFFFFF4F1,
        ), // Secondary background
        cardTheme: CardThemeData(
          elevation: 5,
          shadowColor: Colors.black.withAlpha(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: const Color(0xFF0d9488).withAlpha(1),
              width: 1,
            ),
          ),
          color: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: false,
          backgroundColor: Color(0xFFFFF4F1),
          foregroundColor: Color(0xFF1A1C1E),
          titleTextStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1C1E),
            letterSpacing: 0.5,
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(foregroundColor: const Color(0xFF0d9488)),
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1C1E),
            letterSpacing: 0,
          ),
          titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1C1E),
          ),
          bodyLarge: TextStyle(fontSize: 16, color: Color(0xFF43474E)),
          bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF43474E)),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0d9488),
          brightness: Brightness.dark,
          primary: const Color(0xFF4DD0C0),
          secondary: const Color(0xFF4DD0C0),
          surface: const Color(0xFF1A1C1E),
          error: const Color(0xFFFFB4AB),
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: const Color(0xFF4DD0C0).withAlpha(51),
              width: 1,
            ),
          ),
          color: const Color(0xFF1E1E1E),
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Color(0xFF121212),
          foregroundColor: Color(0xFFE3E3E3),
        ),
      ),
      home: Stack(children: const [QuickActionsInitializer(), MainScreen()]),
    );
  }
}
