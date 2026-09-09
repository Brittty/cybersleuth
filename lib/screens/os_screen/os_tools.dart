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
    final evidenceCount = ref
        .watch(investigationProvider)
        .markedEvidence
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(top: 8),
            children: [
              for (final tool in osToolsList)
                _AppButton(
                  label: tool.name,
                  icon: tool.iconData,
                  selected: osState.activeTool?.id == tool.id,
                  onTap: () =>
                      ref.read(osScreenProvider.notifier).setActiveTool(tool),
                ),
            ],
          ),
        ),
        _AppButton(
          label: 'Report',
          icon: Icons.assignment_outlined,
          badgeCount: evidenceCount,
          onTap: () => ref
              .read(globalStateProvider.notifier)
              .setScreen(AppScreen.report),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _AppButton extends StatelessWidget {
  const _AppButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.selected = false,
    this.badgeCount = 0,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool selected;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final foreground = selected ? colors.onPrimary : colors.onPrimaryContainer;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: Semantics(
        button: true,
        selected: selected,
        child: Tooltip(
          message: label.replaceAll('\n', ' '),
          child: Material(
            color: selected ? colors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: SizedBox(
                width: double.infinity,
                height: 72,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 8,
                  ),
                  child: Column(
                    children: [
                      Badge(
                        label: Text('$badgeCount'),
                        isLabelVisible: badgeCount > 0,
                        child: Icon(icon, size: 22, color: foreground),
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: Center(
                          child: Text(
                            label,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 9,
                              height: 1.2,
                              fontWeight: FontWeight.w500,
                              color: foreground,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
