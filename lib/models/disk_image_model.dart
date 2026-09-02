import 'package:cyber_sleuth/models/file_node_model.dart';
import 'package:cyber_sleuth/models/forensic_models.dart';

class DiskImage {
  final String diskId;
  final String ownerName;
  final String ownerRole;
  final String originalHash;
  final FileNode rootDirectory;
  final List<NetworkCapture> networkCaptures;
  final List<AccessLogEntry> accessLogs;
  final List<EmailRecord> emailRecords;

  const DiskImage({
    required this.diskId,
    required this.ownerName,
    required this.ownerRole,
    required this.originalHash,
    required this.rootDirectory,
    this.networkCaptures = const [],
    this.accessLogs = const [],
    this.emailRecords = const [],
  });
}
