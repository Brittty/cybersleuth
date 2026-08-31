import 'package:cyber_sleuth/providers/os_screen_provider.dart';
import 'package:cyber_sleuth/screens/os_screen/os_tools.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OsScreen extends ConsumerStatefulWidget {
  const OsScreen({super.key});

  @override
  ConsumerState<OsScreen> createState() => _OsScreenState();
}

class _OsScreenState extends ConsumerState<OsScreen> {
  Widget getActiveWindow() {
    Widget activeWidget;
    switch (ref.read(osScreenProvider).activeTool?.id) {
      case 1:
        activeWidget = const Center(child: Text("File Explorer Placeholder"));
        break;
      case 2:
        activeWidget = const Center(child: Text("Hex Editor Placeholder"));
        break;
      case 3:
        activeWidget = const Center(child: Text("Network Inspector Placeholder"));
        break;
      case 4:
        activeWidget = const Center(child: Text("Disk Cloner Placeholder"));
        break;
      default:
        activeWidget = const Center(child: Text("Select a tool"));
    }
    return activeWidget;
  }

  @override
  Widget build(BuildContext context) {
    final osState = ref.watch(osScreenProvider);

    return Row(
      children: [
        Container(
          width: 80,
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).colorScheme.primaryContainer,
          ),
          child: OsTools(),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(top: 8, bottom: 8, right: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            child: getActiveWindow(),
          ),
        ),
      ],
    );
  }
}
