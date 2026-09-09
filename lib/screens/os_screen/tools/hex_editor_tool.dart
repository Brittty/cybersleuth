import 'package:cyber_sleuth/models/evidence_model.dart';
import 'package:cyber_sleuth/models/file_node_model.dart';
import 'package:cyber_sleuth/providers/investigation_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HexEditorTool extends ConsumerStatefulWidget {
  final FileNode rootDirectory;
  final String diskId;

  const HexEditorTool({
    super.key,
    required this.rootDirectory,
    required this.diskId,
  });

  @override
  ConsumerState<HexEditorTool> createState() => _HexEditorToolState();
}

class _HexEditorToolState extends ConsumerState<HexEditorTool> {
  FileNode? _selectedFile;
  List<FileNode> _allFiles = [];

  @override
  void initState() {
    super.initState();
    _allFiles = _flattenFiles(widget.rootDirectory);
  }

  @override
  void didUpdateWidget(HexEditorTool oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.diskId != widget.diskId) {
      setState(() {
        _selectedFile = null;
        _allFiles = _flattenFiles(widget.rootDirectory);
      });
    }
  }

  List<FileNode> _flattenFiles(FileNode node) {
    final files = <FileNode>[];
    if (!node.isDirectory && node.hexPreview != null) {
      files.add(node);
    }
    for (final child in node.children) {
      files.addAll(_flattenFiles(child));
    }
    return files;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final investigationState = ref.watch(investigationProvider);

    return Row(
      children: [
        // File list panel
        SizedBox(
          width: 280,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(color: colorScheme.outline.withAlpha(40)),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.data_array,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Files',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: colorScheme.outline.withAlpha(40)),
                Expanded(
                  child: ListView.builder(
                    itemCount: _allFiles.length,
                    itemBuilder: (context, index) {
                      final file = _allFiles[index];
                      final isSelected = _selectedFile?.id == file.id;
                      final isMarked = investigationState.isMarked(file.id);
                      return InkWell(
                        onTap: () => setState(() => _selectedFile = file),
                        child: Container(
                          color: isSelected
                              ? colorScheme.primary.withAlpha(30)
                              : Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.insert_drive_file,
                                size: 14,
                                color: isMarked
                                    ? colorScheme.primary
                                    : colorScheme.onSurface.withAlpha(150),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      file.name,
                                      style: TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 11,
                                        color: isMarked
                                            ? colorScheme.primary
                                            : colorScheme.onSurface,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      file.displaySize,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: colorScheme.onSurface.withAlpha(
                                          100,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isMarked)
                                Icon(
                                  Icons.bookmark,
                                  size: 14,
                                  color: colorScheme.primary,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        // Hex view panel
        Expanded(
          child: _selectedFile == null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.data_array,
                        size: 48,
                        color: colorScheme.onSurface.withAlpha(60),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Select a file to view hex dump',
                        style: TextStyle(
                          color: colorScheme.onSurface.withAlpha(100),
                        ),
                      ),
                    ],
                  ),
                )
              : _buildHexView(_selectedFile!, colorScheme, investigationState),
        ),
      ],
    );
  }

  Widget _buildHexView(
    FileNode file,
    ColorScheme colorScheme,
    InvestigationState investigationState,
  ) {
    final isMarked = investigationState.isMarked(file.id);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Size: ${file.displaySize}\nModified: ${file.lastModified}',
                      style: TextStyle(
                        color: colorScheme.onSurface.withAlpha(150),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: () {
                  ref
                      .read(investigationProvider.notifier)
                      .toggleEvidence(
                        MarkedEvidence(
                          id: file.id,
                          diskId: widget.diskId,
                          category: 'hex',
                          title: '${file.name} (hex)',
                          description:
                              'Hex analysis of ${file.name} (${file.displaySize})',
                        ),
                      );
                },
                icon: Icon(
                  isMarked ? Icons.bookmark : Icons.bookmark_border,
                  size: 18,
                ),
                label: Text(isMarked ? 'Marked' : 'Mark Evidence'),
                style: FilledButton.styleFrom(
                  backgroundColor: isMarked
                      ? colorScheme.primary
                      : colorScheme.surfaceContainerHighest,
                  foregroundColor: isMarked
                      ? colorScheme.onPrimary
                      : colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Column headers
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  child: Text(
                    'Offset',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Hexadecimal',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'ASCII',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Hex content
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1117),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(8),
                ),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  file.hexPreview ?? 'No hex data available',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: Color(0xFF7EE787),
                    height: 1.6,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),

          // Signature detection
          if (_detectSignature(file) != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.tertiaryContainer.withAlpha(60),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorScheme.tertiary.withAlpha(80)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 18,
                    color: colorScheme.tertiary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _detectSignature(file)!,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String? _detectSignature(FileNode file) {
    if (file.hexPreview == null) return null;
    final hex = file.hexPreview!.toLowerCase();

    if (hex.contains('8c 0d 04 09')) {
      return 'File signature: GPG/OpenPGP symmetrically encrypted data (AES-256-CFB)';
    }
    if (hex.contains('25 50 44 46')) {
      return 'File signature: PDF document (ISO 32000)';
    }
    if (hex.contains('23 21 2f 62 69 6e')) {
      return 'File signature: Unix shell script (#!/bin/)';
    }
    if (hex.contains('7b 0a')) {
      return 'File signature: JSON data';
    }
    return null;
  }
}
