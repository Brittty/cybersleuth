import 'package:cyber_sleuth/providers/contract_provider.dart';
import 'package:cyber_sleuth/models/disk_image_model.dart';
import 'package:cyber_sleuth/providers/investigation_provider.dart';
import 'package:cyber_sleuth/providers/os_screen_provider.dart';
import 'package:cyber_sleuth/screens/os_screen/os_tools.dart';
import 'package:cyber_sleuth/screens/os_screen/tools/access_log_viewer_tool.dart';
import 'package:cyber_sleuth/screens/os_screen/tools/email_viewer_tool.dart';
import 'package:cyber_sleuth/screens/os_screen/tools/file_explorer_tool.dart';
import 'package:cyber_sleuth/screens/os_screen/tools/hex_editor_tool.dart';
import 'package:cyber_sleuth/screens/os_screen/tools/network_analyzer_tool.dart';
import 'package:cyber_sleuth/screens/os_screen/tools/notepad_tool.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OsScreen extends ConsumerStatefulWidget {
  const OsScreen({super.key});

  @override
  ConsumerState<OsScreen> createState() => _OsScreenState();
}

class _OsScreenState extends ConsumerState<OsScreen> {
  late final List<DiskImage> _disks;

  @override
  void initState() {
    super.initState();
    final contract = ref.read(activeContractProvider);
    _disks = contract.caseData!.diskImages;
  }

  Widget _getActiveWindow(DiskImage disk) {
    final activeTool = ref.watch(osScreenProvider).activeTool;
    switch (activeTool?.id) {
      case 1:
        return FileExplorerTool(
          rootDirectory: disk.rootDirectory,
          diskId: disk.diskId,
        );
      case 2:
        return HexEditorTool(
          rootDirectory: disk.rootDirectory,
          diskId: disk.diskId,
        );
      case 3:
        return NetworkAnalyzerTool(
          captures: disk.networkCaptures,
          diskId: disk.diskId,
        );
      case 4:
        return AccessLogViewerTool(
          accessLogs: disk.accessLogs,
          diskId: disk.diskId,
        );
      case 5:
        return EmailViewerTool(emails: disk.emailRecords, diskId: disk.diskId);
      case 6:
        final caseId = ref.watch(activeContractProvider).id;
        return NotepadTool(key: ValueKey(caseId), caseId: caseId);
      default:
        return _buildWelcomeView();
    }
  }

  Widget _buildWelcomeView() {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search,
            size: 64,
            color: colorScheme.primary.withAlpha(100),
          ),
          const SizedBox(height: 16),
          Text(
            'Select a tool to begin investigation',
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.onSurface.withAlpha(150),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Use the sidebar to choose a forensic tool.\nSwitch between disk images using the tabs above.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurface.withAlpha(100),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final investigationState = ref.watch(investigationProvider);
    final selectedDiskId =
        investigationState.selectedDiskId ?? _disks.first.diskId;
    final selectedDisk = _disks.firstWhere((d) => d.diskId == selectedDiskId);

    return Column(
      children: [
        // Disk selector tabs
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(color: colorScheme.surfaceContainerHighest),
          child: Row(
            children: [
              Icon(Icons.sd_storage, size: 16, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'DISK:',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              ..._disks.map((disk) {
                final isActive = disk.diskId == selectedDiskId;
                return Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: InkWell(
                    onTap: () {
                      ref
                          .read(investigationProvider.notifier)
                          .selectDisk(disk.diskId);
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? colorScheme.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: isActive
                            ? null
                            : Border.all(
                                color: colorScheme.outline.withAlpha(60),
                              ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            disk.diskId,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isActive
                                  ? colorScheme.onPrimary
                                  : colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            '${disk.ownerName} (${disk.ownerRole})',
                            style: TextStyle(
                              fontSize: 9,
                              color: isActive
                                  ? colorScheme.onPrimary.withAlpha(200)
                                  : colorScheme.onSurface.withAlpha(150),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const Spacer(),
              // Evidence count badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bookmark, size: 14, color: colorScheme.primary),
                    const SizedBox(width: 4),
                    Text(
                      '${investigationState.markedEvidence.length} marked',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Main content
        Expanded(
          child: Row(
            children: [
              // Tool sidebar
              Container(
                width: 80,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: colorScheme.primaryContainer,
                ),
                child: const OsTools(),
              ),
              // Active tool view
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 8, bottom: 8, right: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: colorScheme.surfaceContainerHighest,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _getActiveWindow(selectedDisk),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
