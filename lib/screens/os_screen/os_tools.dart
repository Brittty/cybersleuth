import 'package:cyber_sleuth/providers/global_state_provider.dart';
import 'package:cyber_sleuth/providers/investigation_provider.dart';
import 'package:cyber_sleuth/providers/os_screen_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OsTools extends ConsumerWidget {
  const OsTools({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final osState = ref.watch(osScreenProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final evidenceCount = ref
        .watch(investigationProvider)
        .markedEvidence
        .length;

    return Column(
      children: [
        const SizedBox(height: 8),
        // Investigation tools
        ...osToolsList.map((tool) {
          final isActive = osState.activeTool?.id == tool.id;
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
            decoration: BoxDecoration(
              color: isActive
                  ? colorScheme.onPrimary.withAlpha(50)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                ref.read(osScreenProvider.notifier).setActiveTool(tool);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      tool.iconData,
                      size: 22,
                      color: isActive
                          ? colorScheme.surface
                          : colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      tool.name,
                      style: TextStyle(
                        fontSize: 9,
                        color: isActive
                            ? colorScheme.surface
                            : colorScheme.onPrimaryContainer,
                        fontWeight: isActive
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),

        const Spacer(),

        // Evidence board indicator
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              // Navigate to report screen
              ref
                  .read(globalStateProvider.notifier)
                  .setScreen(AppScreen.report);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Column(
                children: [
                  Badge(
                    label: Text('$evidenceCount'),
                    isLabelVisible: evidenceCount > 0,
                    child: Icon(
                      Icons.assignment_outlined,
                      size: 22,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Report',
                    style: TextStyle(
                      fontSize: 9,
                      color: colorScheme.onPrimaryContainer,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
