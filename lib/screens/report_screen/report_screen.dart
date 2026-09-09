import 'package:cyber_sleuth/providers/contract_provider.dart';
import 'package:cyber_sleuth/models/disk_image_model.dart';
import 'package:cyber_sleuth/providers/global_state_provider.dart';
import 'package:cyber_sleuth/providers/investigation_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key});

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  late final List<DiskImage> _disks;

  @override
  void initState() {
    super.initState();
    final contract = ref.read(activeContractProvider);
    _disks = contract.caseData!.diskImages;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final investigationState = ref.watch(investigationProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        ref
                            .read(globalStateProvider.notifier)
                            .setScreen(AppScreen.os);
                      },
                      icon: Icon(
                        Icons.arrow_back,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.assignment,
                      color: colorScheme.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Investigation Report',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section 1: Suspect Selection
                        _sectionHeader(
                          'Step 1: Identify Implicated Device',
                          colorScheme,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Select the device involved in the incident. Its owner may be a victim.',
                          style: TextStyle(
                            color: colorScheme.onSurface.withAlpha(180),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ..._disks.map((disk) {
                          final isSelected =
                              investigationState.playerSuspectDiskId ==
                              disk.diskId;
                          return InkWell(
                            onTap: () {
                              ref
                                  .read(investigationProvider.notifier)
                                  .setSuspectDisk(disk.diskId);
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? colorScheme.primary.withAlpha(20)
                                    : colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? colorScheme.primary
                                      : colorScheme.outline.withAlpha(40),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    margin: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected
                                            ? colorScheme.primary
                                            : colorScheme.outline,
                                        width: 2,
                                      ),
                                    ),
                                    child: isSelected
                                        ? Center(
                                            child: Container(
                                              width: 10,
                                              height: 10,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: colorScheme.primary,
                                              ),
                                            ),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.sd_storage,
                                    color: colorScheme.primary,
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        disk.diskId,
                                        style: TextStyle(
                                          fontFamily: 'monospace',
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                      Text(
                                        '${disk.ownerName} (${disk.ownerRole})',
                                        style: TextStyle(
                                          color: colorScheme.onSurface
                                              .withAlpha(150),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 24),

                        // Section 2: Evidence Summary
                        _sectionHeader(
                          'Step 2: Evidence Summary '
                          '(${investigationState.markedEvidence.length} items)',
                          colorScheme,
                        ),
                        const SizedBox(height: 12),
                        if (investigationState.markedEvidence.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                'No evidence marked. Go back and mark relevant findings.',
                                style: TextStyle(
                                  color: colorScheme.onSurface.withAlpha(130),
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          )
                        else
                          ...investigationState.markedEvidence.map((evidence) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: colorScheme.outline.withAlpha(30),
                                ),
                              ),
                              child: Row(
                                children: [
                                  _categoryIcon(evidence.category, colorScheme),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: colorScheme.primary
                                                    .withAlpha(30),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                evidence.diskId,
                                                style: TextStyle(
                                                  fontFamily: 'monospace',
                                                  fontSize: 9,
                                                  color: colorScheme.primary,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                evidence.title,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13,
                                                  color: colorScheme.onSurface,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          evidence.description,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: colorScheme.onSurface
                                                .withAlpha(150),
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.remove_circle_outline,
                                      size: 18,
                                      color: colorScheme.error,
                                    ),
                                    onPressed: () {
                                      ref
                                          .read(investigationProvider.notifier)
                                          .unmarkEvidence(evidence.id);
                                    },
                                  ),
                                ],
                              ),
                            );
                          }),

                        const SizedBox(height: 24),

                        // Section 3: Timeline
                        _sectionHeader(
                          'Step 3: Reconstructed Timeline (optional)',
                          colorScheme,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Arrange the key incident events in chronological order. Timeline points depend on both completeness and order. Supporting evidence adds context without a bonus or penalty.',
                          style: TextStyle(
                            color: colorScheme.onSurface.withAlpha(150),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildTimelineSection(investigationState, colorScheme),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed:
                        investigationState.playerSuspectDiskId != null &&
                            investigationState.markedEvidence.isNotEmpty
                        ? () {
                            ref
                                .read(globalStateProvider.notifier)
                                .setScreen(AppScreen.scoring);
                          }
                        : null,
                    icon: const Icon(Icons.send),
                    label: const Text('Submit Report'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineSection(
    InvestigationState state,
    ColorScheme colorScheme,
  ) {
    final available = state.markedEvidence
        .where((e) => !state.playerTimeline.contains(e.id))
        .toList();
    final inTimeline = state.playerTimeline
        .map(
          (id) => state.markedEvidence.firstWhere(
            (e) => e.id == id,
            orElse: () => state.markedEvidence.first,
          ),
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline items
        if (state.playerTimeline.isNotEmpty) ...[
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: inTimeline.length,
            // ignore: deprecated_member_use
            onReorder: (oldIdx, newIdx) {
              ref
                  .read(investigationProvider.notifier)
                  .reorderTimeline(oldIdx, newIdx);
            },
            itemBuilder: (context, index) {
              final evidence = inTimeline[index];
              return Container(
                key: ValueKey(evidence.id),
                margin: const EdgeInsets.only(bottom: 4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withAlpha(60),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colorScheme.primary.withAlpha(40)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.drag_handle,
                      size: 16,
                      color: colorScheme.onSurface.withAlpha(100),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.primary,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        evidence.title,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.remove_circle_outline,
                        size: 16,
                        color: colorScheme.error,
                      ),
                      onPressed: () {
                        ref
                            .read(investigationProvider.notifier)
                            .removeFromTimeline(evidence.id);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 8),
        ],

        // Available items to add
        if (available.isNotEmpty) ...[
          Text(
            'Add to timeline:',
            style: TextStyle(
              fontSize: 11,
              color: colorScheme.onSurface.withAlpha(130),
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: available.map((evidence) {
              return ActionChip(
                avatar: Icon(Icons.add, size: 14, color: colorScheme.primary),
                label: Text(
                  evidence.title,
                  style: TextStyle(fontSize: 10, color: colorScheme.onSurface),
                ),
                onPressed: () {
                  ref
                      .read(investigationProvider.notifier)
                      .addToTimeline(evidence.id);
                },
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _sectionHeader(String title, ColorScheme colorScheme) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: colorScheme.onSurface,
      ),
    );
  }

  Widget _categoryIcon(String category, ColorScheme colorScheme) {
    IconData icon;
    Color color;
    switch (category) {
      case 'file':
        icon = Icons.folder;
        color = Colors.amber;
        break;
      case 'hex':
        icon = Icons.data_array;
        color = Colors.green;
        break;
      case 'network':
        icon = Icons.lan;
        color = Colors.blue;
        break;
      case 'access_log':
        icon = Icons.history;
        color = Colors.orange;
        break;
      case 'email':
        icon = Icons.email;
        color = Colors.purple;
        break;
      default:
        icon = Icons.help;
        color = Colors.grey;
    }
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 18, color: color),
    );
  }
}
