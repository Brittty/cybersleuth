import 'package:cyber_sleuth/screens/chain_of_custody_screen/chain_of_custody_screen.dart';
import 'package:cyber_sleuth/screens/messaging_screen/messaging_screen.dart';
import 'package:cyber_sleuth/screens/os_screen/os_screen.dart';
import 'package:cyber_sleuth/screens/report_screen/report_screen.dart';
import 'package:cyber_sleuth/screens/scoring_screen/scoring_screen.dart';
import 'package:cyber_sleuth/providers/global_state_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CyberSleuth',
      debugShowCheckedModeBanner: false,
      theme: _buildForensicTheme(),
      home: const MyHomePage(),
    );
  }

  ThemeData _buildForensicTheme() {
    const background = Color(0xFFF8F9FA);
    const surface = Color(0xFFFFFFFF);
    const surfaceContainer = Color(0xFFF1F3F5);
    const surfaceContainerHighest = Color(0xFFE9ECEF);
    const primary = Color(0xFF187347);
    const secondary = Color(0xFF4C6EF5);
    const error = Color(0xFFBA1A1A);
    const onSurface = Color(0xFF212529);
    const onSurfaceDim = Color(0xFF495057);
    const outline = Color(0xFFCED4DA);

    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.light(
        surface: surface,
        onSurface: onSurface,
        primary: primary,
        onPrimary: Color(0xFFFFFFFF),
        primaryContainer: Color(0xFFD5F3E1),
        onPrimaryContainer: Color(0xFF0B3B24),
        secondary: secondary,
        onSecondary: Color(0xFFFFFFFF),
        secondaryContainer: Color(0xFFDBE4FF),
        onSecondaryContainer: Color(0xFF183087),
        onSurfaceVariant: onSurfaceDim,
        error: error,
        onError: Color(0xFFFFFFFF),
        outline: outline,
        surfaceContainerHighest: surfaceContainerHighest,
        surfaceContainerHigh: surfaceContainer,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: onSurface),
        bodyMedium: TextStyle(color: onSurface),
        bodySmall: TextStyle(color: onSurfaceDim),
        titleLarge: TextStyle(color: onSurface, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(color: onSurface),
        headlineMedium: TextStyle(color: onSurface),
        headlineSmall: TextStyle(color: onSurface),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: const Color(0xFFFFFFFF),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainer,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
      ),
      dividerTheme: const DividerThemeData(color: outline, thickness: 1),
      dropdownMenuTheme: const DropdownMenuThemeData(
        textStyle: TextStyle(color: onSurface, fontSize: 13),
      ),
    );
  }
}

class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final globalState = ref.watch(globalStateProvider);

    Widget screen;
    switch (globalState.currentScreen) {
      case AppScreen.messaging:
        screen = const MessagingScreen();
        break;
      case AppScreen.chainOfCustody:
        screen = const ChainOfCustodyScreen();
        break;
      case AppScreen.os:
        screen = const OsScreen();
        break;
      case AppScreen.report:
        screen = const ReportScreen();
        break;
      case AppScreen.scoring:
        screen = const ScoringScreen();
        break;
    }

    return Scaffold(body: screen);
  }
}
