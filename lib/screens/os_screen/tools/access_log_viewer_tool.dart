import 'package:cyber_sleuth/models/evidence_model.dart';
import 'package:cyber_sleuth/models/forensic_models.dart';
import 'package:cyber_sleuth/providers/investigation_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccessLogViewerTool extends ConsumerStatefulWidget {
  final List<AccessLogEntry> accessLogs;
  final String diskId;

  const AccessLogViewerTool({
    super.key,
    required this.accessLogs,
    required this.diskId,
  });

  @override
  ConsumerState<AccessLogViewerTool> createState() =>
      _AccessLogViewerToolState();
}

class _AccessLogViewerToolState extends ConsumerState<AccessLogViewerTool> {
  String _actionFilter = 'All';
  String _timeFilter = 'All';

  List<AccessLogEntry> get _filteredLogs {
    var logs = widget.accessLogs;
    if (_actionFilter != 'All') {
      logs = logs.where((l) => l.action == _actionFilter).toList();
    }
    if (_timeFilter == 'After Hours') {
      logs = logs.where((l) {
        final hour = int.tryParse(l.timestamp.split(' ')[1].split(':')[0]) ?? 0;
        return hour >= 20 || hour < 6;
      }).toList();
    } else if (_timeFilter == 'Business Hours') {
      logs = logs.where((l) {
        final hour = int.tryParse(l.timestamp.split(' ')[1].split(':')[0]) ?? 0;
        return hour >= 6 && hour < 20;
      }).toList();
    }
    return logs;
  }

  Set<String> get _actions {
    return {'All', ...widget.accessLogs.map((l) => l.action)};
  }

  @override
  void didUpdateWidget(AccessLogViewerTool oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.diskId != widget.diskId) {
      setState(() {
        _actionFilter = 'All';
        _timeFilter = 'All';
      });
    }
  }

  bool _isAfterHours(String timestamp) {
    final hour =
        int.tryParse(timestamp.split(' ')[1].split(':')[0]) ?? 0;
    return hour >= 20 || hour < 6;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final investigationState = ref.watch(investigationProvider);

    return Column(
      children: [
        // Toolbar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: colorScheme.outline.withAlpha(40)),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.history, color: colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Access Logs',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              // Action filter
              Text('Action: ',
                  style: TextStyle(
                      color: colorScheme.onSurface.withAlpha(150),
                      fontSize: 12)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: DropdownButton<String>(
                  value: _actionFilter,
                  underline: const SizedBox.shrink(),
                  dropdownColor: colorScheme.surfaceContainerHighest,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    color: colorScheme.onSurface,
                  ),
                  items: _actions
                      .map(
                          (a) => DropdownMenuItem(value: a, child: Text(a)))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _actionFilter = v ?? 'All'),
                ),
              ),
              const SizedBox(width: 12),
              // Time filter
              Text('Time: ',
                  style: TextStyle(
                      color: colorScheme.onSurface.withAlpha(150),
                      fontSize: 12)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: DropdownButton<String>(
                  value: _timeFilter,
                  underline: const SizedBox.shrink(),
                  dropdownColor: colorScheme.surfaceContainerHighest,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    color: colorScheme.onSurface,
                  ),
                  items: ['All', 'Business Hours', 'After Hours']
                      .map(
                          (t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _timeFilter = v ?? 'All'),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '${_filteredLogs.length} entries',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: colorScheme.onSurface.withAlpha(150),
                ),
              ),
            ],
          ),
        ),

        // Table header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: colorScheme.surfaceContainerHighest,
          child: Row(
            children: [
              _headerCell('Timestamp', 160, colorScheme),
              _headerCell('User', 130, colorScheme),
              _headerCell('Action', 110, colorScheme),
              Expanded(
                child: Text('Target',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    )),
              ),
              _headerCell('Status', 70, colorScheme),
              const SizedBox(width: 40),
            ],
          ),
        ),

        // Log rows
        Expanded(
          child: ListView.builder(
            itemCount: _filteredLogs.length,
            itemBuilder: (context, index) {
              final log = _filteredLogs[index];
              final isMarked = investigationState.isMarked(log.id);
              final isAfterHours = _isAfterHours(log.timestamp);

              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isAfterHours
                      ? const Color(0xFFFFB800).withAlpha(10)
                      : Colors.transparent,
                  border: Border(
                    bottom: BorderSide(
                        color: colorScheme.outline.withAlpha(20)),
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 160,
                      child: Row(
                        children: [
                          if (isAfterHours)
                            Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Icon(Icons.nightlight_round,
                                  size: 12,
                                  color: const Color(0xFFFFB800)),
                            ),
                          Text(
                            log.timestamp,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                              color: isAfterHours
                                  ? const Color(0xFFFFB800)
                                  : colorScheme.onSurface.withAlpha(200),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 130,
                      child: Text(
                        log.user,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          color: colorScheme.onSurface.withAlpha(200),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(
                      width: 110,
                      child: _actionChip(log.action, colorScheme),
                    ),
                    Expanded(
                      child: Text(
                        log.target,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          color: colorScheme.onSurface.withAlpha(200),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(
                      width: 70,
                      child: Text(
                        log.status,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 10,
                          color: log.status == 'SUCCESS'
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        ref
                            .read(investigationProvider.notifier)
                            .toggleEvidence(
                              MarkedEvidence(
                                id: log.id,
                                diskId: widget.diskId,
                                category: 'access_log',
                                title:
                                    '${log.action} → ${log.target}',
                                description:
                                    '${log.user} | ${log.timestamp} | ${log.action} → ${log.target} [${log.status}]',
                              ),
                            );
                      },
                      child: Icon(
                        isMarked ? Icons.bookmark : Icons.bookmark_border,
                        size: 16,
                        color: isMarked
                            ? colorScheme.primary
                            : colorScheme.onSurface.withAlpha(80),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _headerCell(String text, double width, ColorScheme colorScheme) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: colorScheme.primary,
        ),
      ),
    );
  }

  Widget _actionChip(String action, ColorScheme colorScheme) {
    Color chipColor;
    switch (action) {
      case 'SSH_LOGIN':
        chipColor = Colors.teal;
        break;
      case 'SSH_LOGOUT':
        chipColor = Colors.blueGrey;
        break;
      case 'FILE_ACCESS':
        chipColor = Colors.orange;
        break;
      case 'FILE_COPY':
        chipColor = Colors.red;
        break;
      case 'SERVICE_RESTART':
        chipColor = Colors.purple;
        break;
      case 'DEPLOY':
        chipColor = Colors.green;
        break;
      default:
        chipColor = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: chipColor.withAlpha(30),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        action,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: chipColor,
        ),
      ),
    );
  }
}
