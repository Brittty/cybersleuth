import 'package:cyber_sleuth/models/evidence_model.dart';
import 'package:cyber_sleuth/models/forensic_models.dart';
import 'package:cyber_sleuth/providers/investigation_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NetworkAnalyzerTool extends ConsumerStatefulWidget {
  final List<NetworkCapture> captures;
  final String diskId;

  const NetworkAnalyzerTool({
    super.key,
    required this.captures,
    required this.diskId,
  });

  @override
  ConsumerState<NetworkAnalyzerTool> createState() =>
      _NetworkAnalyzerToolState();
}

class _NetworkAnalyzerToolState extends ConsumerState<NetworkAnalyzerTool> {
  String _protocolFilter = 'All';
  NetworkCapture? _selectedCapture;

  List<NetworkCapture> get _filteredCaptures {
    if (_protocolFilter == 'All') return widget.captures;
    return widget.captures
        .where((c) => c.protocol == _protocolFilter)
        .toList();
  }

  Set<String> get _protocols {
    return {'All', ...widget.captures.map((c) => c.protocol)};
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  @override
  void didUpdateWidget(NetworkAnalyzerTool oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.diskId != widget.diskId) {
      setState(() {
        _protocolFilter = 'All';
        _selectedCapture = null;
      });
    }
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
              Icon(Icons.lan_outlined,
                  color: colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Network Analyzer',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Text('Protocol: ',
                  style: TextStyle(
                      color: colorScheme.onSurface.withAlpha(150),
                      fontSize: 12)),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: DropdownButton<String>(
                  value: _protocolFilter,
                  underline: const SizedBox.shrink(),
                  dropdownColor: colorScheme.surfaceContainerHighest,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: colorScheme.onSurface,
                  ),
                  items: _protocols
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _protocolFilter = v ?? 'All'),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '${_filteredCaptures.length} packets',
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
              _headerCell('Time', 140),
              _headerCell('Source', 120),
              _headerCell('Destination', 120),
              _headerCell('Protocol', 70),
              _headerCell('Length', 80),
              Expanded(
                child: Text('Info',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    )),
              ),
              const SizedBox(width: 40), // for bookmark icon
            ],
          ),
        ),

        // Packet rows
        Expanded(
          child: ListView.builder(
            itemCount: _filteredCaptures.length,
            itemBuilder: (context, index) {
              final capture = _filteredCaptures[index];
              final isSelected = _selectedCapture?.id == capture.id;
              final isMarked = investigationState.isMarked(capture.id);
              final isExternal =
                  !capture.destIp.startsWith('10.') && capture.destIp != '127.0.0.1';

              return InkWell(
                onTap: () => setState(() => _selectedCapture =
                    isSelected ? null : capture),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.primary.withAlpha(20)
                        : isExternal
                            ? colorScheme.error.withAlpha(10)
                            : Colors.transparent,
                    border: Border(
                      bottom: BorderSide(
                          color: colorScheme.outline.withAlpha(20)),
                    ),
                  ),
                  child: Row(
                    children: [
                      _dataCell(capture.timestamp.split(' ').last, 140,
                          colorScheme),
                      _dataCell(capture.sourceIp, 120, colorScheme),
                      _dataCell(capture.destIp, 120, colorScheme,
                          highlight: isExternal),
                      _protocolChip(capture.protocol, colorScheme),
                      _dataCell(_formatBytes(capture.bytes), 80, colorScheme),
                      Expanded(
                        child: Text(
                          capture.info,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            color: colorScheme.onSurface.withAlpha(200),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          ref
                              .read(investigationProvider.notifier)
                              .toggleEvidence(
                                MarkedEvidence(
                                  id: capture.id,
                                  diskId: widget.diskId,
                                  category: 'network',
                                  title:
                                      '${capture.protocol} ${capture.sourceIp} → ${capture.destIp}',
                                  description: capture.info,
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
                ),
              );
            },
          ),
        ),

        // Detail panel (when a capture is selected)
        if (_selectedCapture != null)
          _buildDetailPanel(_selectedCapture!, colorScheme, investigationState),
      ],
    );
  }

  Widget _headerCell(String text, double width) {
    final colorScheme = Theme.of(context).colorScheme;
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

  Widget _dataCell(String text, double width, ColorScheme colorScheme,
      {bool highlight = false}) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 11,
          color: highlight
              ? colorScheme.error
              : colorScheme.onSurface.withAlpha(200),
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _protocolChip(String protocol, ColorScheme colorScheme) {
    Color chipColor;
    switch (protocol) {
      case 'SSH':
        chipColor = Colors.teal;
        break;
      case 'HTTPS':
        chipColor = Colors.green;
        break;
      case 'HTTP':
        chipColor = Colors.blue;
        break;
      case 'DNS':
        chipColor = Colors.orange;
        break;
      case 'SMTP':
        chipColor = Colors.red;
        break;
      default:
        chipColor = Colors.grey;
    }
    return SizedBox(
      width: 70,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: chipColor.withAlpha(30),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          protocol,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: chipColor,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildDetailPanel(NetworkCapture capture, ColorScheme colorScheme,
      InvestigationState investigationState) {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        border: Border(
          top: BorderSide(color: colorScheme.outline.withAlpha(40)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Packet Details',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    )),
                const SizedBox(height: 8),
                _detailRow('Timestamp', capture.timestamp, colorScheme),
                _detailRow('Source', capture.sourceIp, colorScheme),
                _detailRow('Destination', capture.destIp, colorScheme),
                _detailRow('Protocol', capture.protocol, colorScheme),
                _detailRow('Size', _formatBytes(capture.bytes), colorScheme),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Summary',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    )),
                const SizedBox(height: 8),
                Text(
                  capture.info,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: colorScheme.onSurface.withAlpha(200),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(label,
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.onSurface.withAlpha(130),
                )),
          ),
          Text(value,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                color: colorScheme.onSurface,
              )),
        ],
      ),
    );
  }
}
