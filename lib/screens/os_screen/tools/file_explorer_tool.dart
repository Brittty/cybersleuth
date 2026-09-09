import 'package:cyber_sleuth/models/evidence_model.dart';
import 'package:cyber_sleuth/models/file_node_model.dart';
import 'package:cyber_sleuth/providers/investigation_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FileExplorerTool extends ConsumerStatefulWidget {
  final FileNode rootDirectory;
  final String diskId;

  const FileExplorerTool({
    super.key,
    required this.rootDirectory,
    required this.diskId,
  });

  @override
  ConsumerState<FileExplorerTool> createState() => _FileExplorerToolState();
}

class _FileExplorerToolState extends ConsumerState<FileExplorerTool> {
  FileNode? _selectedFile;
  final Set<String> _expandedDirs = {};

  @override
  void initState() {
    super.initState();
    // Auto-expand the root
    _expandedDirs.add(widget.rootDirectory.id);
  }

  @override
  void didUpdateWidget(FileExplorerTool oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.diskId != widget.diskId) {
      setState(() {
        _selectedFile = null;
        _expandedDirs.clear();
        _expandedDirs.add(widget.rootDirectory.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final investigationState = ref.watch(investigationProvider);

    return Row(
      children: [
        // File tree panel
        SizedBox(
          width: 320,
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
                        Icons.folder_outlined,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'File System',
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
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: _buildTreeNode(
                      widget.rootDirectory,
                      0,
                      colorScheme,
                      investigationState,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // File detail panel
        Expanded(
          child: _selectedFile == null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.touch_app_outlined,
                        size: 48,
                        color: colorScheme.onSurface.withAlpha(60),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Select a file to view details',
                        style: TextStyle(
                          color: colorScheme.onSurface.withAlpha(100),
                        ),
                      ),
                    ],
                  ),
                )
              : _buildFileDetails(
                  _selectedFile!,
                  colorScheme,
                  investigationState,
                ),
        ),
      ],
    );
  }

  Widget _buildTreeNode(
    FileNode node,
    int depth,
    ColorScheme colorScheme,
    InvestigationState investigationState,
  ) {
    final isExpanded = _expandedDirs.contains(node.id);
    final isSelected = _selectedFile?.id == node.id;
    final isMarked = investigationState.isMarked(node.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              if (node.isDirectory) {
                if (isExpanded) {
                  _expandedDirs.remove(node.id);
                } else {
                  _expandedDirs.add(node.id);
                }
              } else {
                _selectedFile = node;
              }
            });
          },
          child: Container(
            color: isSelected
                ? colorScheme.primary.withAlpha(30)
                : Colors.transparent,
            padding: EdgeInsets.only(
              left: 12.0 + depth * 16.0,
              top: 4,
              bottom: 4,
              right: 8,
            ),
            child: Row(
              children: [
                if (node.isDirectory)
                  Icon(
                    isExpanded ? Icons.expand_more : Icons.chevron_right,
                    size: 16,
                    color: colorScheme.onSurface.withAlpha(150),
                  )
                else
                  const SizedBox(width: 16),
                const SizedBox(width: 4),
                Icon(
                  node.isDirectory
                      ? (isExpanded ? Icons.folder_open : Icons.folder)
                      : _getFileIcon(node.name),
                  size: 16,
                  color: node.isDirectory
                      ? Colors.amber
                      : colorScheme.onSurface.withAlpha(180),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    node.name,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: isMarked
                          ? colorScheme.primary
                          : colorScheme.onSurface,
                      fontWeight: isMarked
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isMarked)
                  Icon(Icons.bookmark, size: 14, color: colorScheme.primary),
              ],
            ),
          ),
        ),
        if (node.isDirectory && isExpanded)
          ...node.children.map(
            (child) => _buildTreeNode(
              child,
              depth + 1,
              colorScheme,
              investigationState,
            ),
          ),
      ],
    );
  }

  Widget _buildFileDetails(
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
          // File header
          Row(
            children: [
              Icon(
                _getFileIcon(file.name),
                color: colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  file.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              _evidenceButton(file, isMarked, colorScheme),
            ],
          ),
          const SizedBox(height: 16),

          // Metadata
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _metadataRow('Size', file.displaySize, colorScheme),
                _metadataRow('Modified', file.lastModified, colorScheme),
                _metadataRow(
                  'Type',
                  file.isDirectory ? 'Directory' : _getFileType(file.name),
                  colorScheme,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Content
          if (file.textContent != null) ...[
            Text(
              'Content',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D1117),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    file.textContent!,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: Color(0xFFE6EDF3),
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ] else if (!file.isDirectory) ...[
            Text(
              'Open this binary file in Hex Editor for analysis.',
              style: TextStyle(
                color: colorScheme.onSurface.withAlpha(150),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _evidenceButton(
    FileNode file,
    bool isMarked,
    ColorScheme colorScheme,
  ) {
    return FilledButton.icon(
      onPressed: () {
        ref
            .read(investigationProvider.notifier)
            .toggleEvidence(
              MarkedEvidence(
                id: file.id,
                diskId: widget.diskId,
                category: 'file',
                title: file.name,
                description:
                    'File: ${file.name} (${file.displaySize}, modified ${file.lastModified})',
              ),
            );
      },
      icon: Icon(isMarked ? Icons.bookmark : Icons.bookmark_border, size: 18),
      label: Text(isMarked ? 'Marked' : 'Mark Evidence'),
      style: FilledButton.styleFrom(
        backgroundColor: isMarked
            ? colorScheme.primary
            : colorScheme.surfaceContainerHighest,
        foregroundColor: isMarked
            ? colorScheme.onPrimary
            : colorScheme.onSurface,
      ),
    );
  }

  Widget _metadataRow(String label, String value, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: colorScheme.onSurface.withAlpha(150),
                fontSize: 12,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon(String name) {
    if (name.endsWith('.sh')) return Icons.terminal;
    if (name.endsWith('.txt') || name.endsWith('.md')) return Icons.description;
    if (name.endsWith('.enc')) return Icons.lock;
    if (name.endsWith('.pdf')) return Icons.picture_as_pdf;
    if (name.endsWith('.json')) return Icons.data_object;
    if (name.endsWith('.pub')) return Icons.key;
    if (name.startsWith('.')) return Icons.settings;
    return Icons.insert_drive_file;
  }

  String _getFileType(String name) {
    if (name.endsWith('.sh')) return 'Shell Script';
    if (name.endsWith('.txt')) return 'Text File';
    if (name.endsWith('.md')) return 'Markdown';
    if (name.endsWith('.enc')) return 'Encrypted Archive';
    if (name.endsWith('.pdf')) return 'PDF Document';
    if (name.endsWith('.json')) return 'JSON Data';
    if (name.endsWith('.pub')) return 'Public Key';
    if (name == '.bash_history') return 'Shell History';
    if (name == 'known_hosts') return 'SSH Known Hosts';
    if (name == 'auth.log') return 'Authentication Log';
    return 'File';
  }
}
