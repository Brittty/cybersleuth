import 'package:cyber_sleuth/screens/messaging_screen/messaging_screen.dart';
import 'package:cyber_sleuth/screens/os_screen/os_screen.dart';
import 'package:cyber_sleuth/providers/global_state_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// StateProvider to manage the counter state across the app
final counterProvider = StateProvider<int>((ref) => 0);

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CyberSlueth',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(),
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
      case AppScreen.os:
        screen = const OsScreen();
        break;
    }

    return Scaffold(body: screen);
  }
}
