import 'package:cyber_sleuth/models/case_data_model.dart';
import 'package:cyber_sleuth/providers/investigation_provider.dart';
import 'package:cyber_sleuth/providers/chain_of_custody_provider.dart';

InvestigationScore calculateInvestigationScore(
  InvestigationState investigation,
  ChainOfCustodyState custody,
  CaseData caseData,
) {
  // Suspect identification (30 pts)
  final suspectCorrect =
      investigation.playerSuspectDiskId == caseData.suspectDiskId;

  // Evidence (10 pts each, max 50)
  final markedIds = investigation.markedEvidence.map((e) => e.id).toSet();
  final correctIds = caseData.correctEvidence.map((e) => e.id).toSet();
  final correctFound = markedIds.intersection(correctIds).length;
  final evidencePoints = correctFound * 10;

  // False positives (-5 each)
  final falsePositives = markedIds
      .difference(correctIds.union(caseData.supportingEvidenceIds))
      .length;
  final falsePositivePenalty = falsePositives * 5;

  // Score against all expected pairs, so omitted events lose credit.
  final correctOrder = caseData.correctTimeline
      .map((e) => e.evidenceId)
      .toList();
  final expectedIds = correctOrder.toSet();
  final playerOrder = investigation.playerTimeline
      .where((id) => expectedIds.contains(id) && markedIds.contains(id))
      .toSet()
      .toList();
  final totalPairs = correctOrder.length * (correctOrder.length - 1) ~/ 2;
  var correctPairs = 0;
  for (var i = 0; i < playerOrder.length; i++) {
    for (var j = i + 1; j < playerOrder.length; j++) {
      if (correctOrder.indexOf(playerOrder[i]) <
          correctOrder.indexOf(playerOrder[j])) {
        correctPairs++;
      }
    }
  }
  final timelinePoints = totalPairs == 0
      ? 0
      : (15 * correctPairs / totalPairs).round();

  // Chain of custody (5 pts)
  final custodyPoints = custody.allChecksPassed ? 5 : 0;

  final total =
      (suspectCorrect ? 30 : 0) +
      evidencePoints -
      falsePositivePenalty +
      timelinePoints +
      custodyPoints;

  return InvestigationScore(
    suspectCorrect: suspectCorrect,
    correctEvidenceCount: correctFound,
    evidencePoints: evidencePoints,
    falsePositives: falsePositives,
    falsePositivePenalty: falsePositivePenalty,
    timelinePoints: timelinePoints,
    custodyPoints: custodyPoints,
    total: total.clamp(0, 100),
  );
}

class InvestigationScore {
  final bool suspectCorrect;
  final int correctEvidenceCount;
  final int evidencePoints;
  final int falsePositives;
  final int falsePositivePenalty;
  final int timelinePoints;
  final int custodyPoints;
  final int total;

  const InvestigationScore({
    required this.suspectCorrect,
    required this.correctEvidenceCount,
    required this.evidencePoints,
    required this.falsePositives,
    required this.falsePositivePenalty,
    required this.timelinePoints,
    required this.custodyPoints,
    required this.total,
  });
}
