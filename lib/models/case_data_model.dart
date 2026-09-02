import 'package:cyber_sleuth/models/disk_image_model.dart';
import 'package:cyber_sleuth/models/evidence_model.dart';

/// Contains all investigation data for a contract case.
/// Separated from ContractModel to keep the contract lean
/// and the investigation data self-contained.
class CaseData {
  final List<DiskImage> diskImages;
  final String suspectDiskId;
  final List<CorrectEvidence> correctEvidence;
  final List<TimelineEvent> correctTimeline;

  const CaseData({
    required this.diskImages,
    required this.suspectDiskId,
    required this.correctEvidence,
    required this.correctTimeline,
  });

  DiskImage? getDisk(String diskId) {
    try {
      return diskImages.firstWhere((d) => d.diskId == diskId);
    } catch (_) {
      return null;
    }
  }
}
