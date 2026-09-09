class FileNode {
  final String id;
  final String name;
  final bool isDirectory;
  final int sizeBytes;
  final String lastModified;
  final String? hexPreview;
  final String? textContent;
  final List<FileNode> children;

  const FileNode({
    required this.id,
    required this.name,
    this.isDirectory = false,
    this.sizeBytes = 0,
    this.lastModified = '',
    this.hexPreview,
    this.textContent,
    this.children = const [],
  });

  /// Returns the full path by walking from root, but for simplicity
  /// we encode path info in the id (e.g., "priya:/home/priya/Documents")
  String get displaySize {
    if (isDirectory) return 'Folder';
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
