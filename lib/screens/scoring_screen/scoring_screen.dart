import 'package:cyber_sleuth/assets/contracts/contract_01.dart';
import 'package:cyber_sleuth/models/case_data_model.dart';
import 'package:cyber_sleuth/providers/chain_of_custody_provider.dart';
import 'package:cyber_sleuth/providers/investigation_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScoringScreen extends ConsumerWidget {
  const ScoringScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final investigationState = ref.watch(investigationProvider);
    final custodyState = ref.watch(chainOfCustodyProvider);
    final contract = InsiderThreatContract();
    final caseData = contract.caseData!;

    final score = _calculateScore(investigationState, custodyState, caseData);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 32),

                  // Grade badge
                  _buildGradeBadge(score, colorScheme, theme),
                  const SizedBox(height: 32),

                  // Score breakdown
                  _buildScoreCard(
                    'Suspect Identification',
                    score.suspectCorrect
                        ? 'Correctly identified ${caseData.suspectDiskId}'
                        : 'Incorrect — the suspect was ${caseData.suspectDiskId}',
                    score.suspectCorrect ? 30 : 0,
                    30,
                    score.suspectCorrect,
                    colorScheme,
                  ),
                  _buildScoreCard(
                    'Evidence Found',
                    '${score.correctEvidenceCount} of ${caseData.correctEvidence.length} key evidence items identified',
                    score.evidencePoints,
                    50,
                    score.correctEvidenceCount ==
                        caseData.correctEvidence.length,
                    colorScheme,
                  ),
                  _buildScoreCard(
                    'False Positives',
                    score.falsePositives == 0
                        ? 'No false evidence marked — clean work!'
                        : '${score.falsePositives} incorrect items marked (−${score.falsePositivePenalty} pts)',
                    -score.falsePositivePenalty,
                    0,
                    score.falsePositives == 0,
                    colorScheme,
                  ),
                  _buildScoreCard(
                    'Timeline Accuracy',
                    score.timelinePoints > 0
                        ? 'Timeline order partially or fully correct'
                        : 'Timeline not provided or incorrect',
                    score.timelinePoints,
                    15,
                    score.timelinePoints >= 10,
                    colorScheme,
                  ),
                  _buildScoreCard(
                    'Chain of Custody',
                    score.custodyPoints > 0
                        ? 'All forensic procedures followed correctly'
                        : 'Some procedures were skipped',
                    score.custodyPoints,
                    5,
                    score.custodyPoints == 5,
                    colorScheme,
                  ),

                  const SizedBox(height: 24),

                  // Total
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: colorScheme.primary.withAlpha(60)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'TOTAL SCORE',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: colorScheme.onSurface,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          '${score.total} / 100',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: colorScheme.primary,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Evidence breakdown
                  _buildEvidenceBreakdown(
                      investigationState, caseData, colorScheme),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGradeBadge(
      _ScoreResult score, ColorScheme colorScheme, ThemeData theme) {
    String grade;
    Color gradeColor;
    String label;
    IconData icon;

    if (score.total >= 85) {
      grade = 'GOLD';
      gradeColor = const Color(0xFFFFD700);
      label = 'Outstanding Investigation';
      icon = Icons.emoji_events;
    } else if (score.total >= 60) {
      grade = 'SILVER';
      gradeColor = const Color(0xFFC0C0C0);
      label = 'Solid Work';
      icon = Icons.workspace_premium;
    } else if (score.total >= 30) {
      grade = 'BRONZE';
      gradeColor = const Color(0xFFCD7F32);
      label = 'Needs Improvement';
      icon = Icons.military_tech;
    } else {
      grade = 'FAILED';
      gradeColor = Colors.red;
      label = 'Case Unresolved';
      icon = Icons.error_outline;
    }

    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                gradeColor.withAlpha(80),
                gradeColor.withAlpha(20),
              ],
            ),
            border: Border.all(color: gradeColor, width: 3),
          ),
          child: Icon(icon, size: 56, color: gradeColor),
        ),
        const SizedBox(height: 16),
        Text(
          grade,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: gradeColor,
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurface.withAlpha(180),
          ),
        ),
      ],
    );
  }

  Widget _buildScoreCard(String title, String description, int points,
      int maxPoints, bool success, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: success
                  ? Colors.green.withAlpha(30)
                  : points < 0
                      ? Colors.red.withAlpha(30)
                      : Colors.orange.withAlpha(30),
            ),
            child: Icon(
              success
                  ? Icons.check
                  : points < 0
                      ? Icons.remove
                      : Icons.close,
              size: 20,
              color: success
                  ? Colors.green
                  : points < 0
                      ? Colors.red
                      : Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurface.withAlpha(150),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$points / $maxPoints',
            style: TextStyle(
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: success
                  ? Colors.green
                  : points < 0
                      ? Colors.red
                      : colorScheme.onSurface.withAlpha(150),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvidenceBreakdown(InvestigationState investigationState,
      CaseData caseData, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Evidence Breakdown',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          ...caseData.correctEvidence.map((correct) {
            final found = investigationState.markedEvidence
                .any((m) => m.id == correct.id);
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: found
                    ? Colors.green.withAlpha(15)
                    : Colors.red.withAlpha(15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: found
                      ? Colors.green.withAlpha(50)
                      : Colors.red.withAlpha(50),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    found ? Icons.check_circle : Icons.cancel,
                    size: 18,
                    color: found ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          correct.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          correct.explanation,
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurface.withAlpha(180),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  _ScoreResult _calculateScore(InvestigationState investigation,
      ChainOfCustodyState custody, CaseData caseData) {
    // Suspect identification (30 pts)
    final suspectCorrect =
        investigation.playerSuspectDiskId == caseData.suspectDiskId;

    // Evidence (10 pts each, max 50)
    final markedIds = investigation.markedEvidence.map((e) => e.id).toSet();
    final correctIds = caseData.correctEvidence.map((e) => e.id).toSet();
    final correctFound = markedIds.intersection(correctIds).length;
    final evidencePoints = correctFound * 10;

    // False positives (-5 each)
    final falsePositives = markedIds.difference(correctIds).length;
    final falsePositivePenalty = falsePositives * 5;

    // Timeline (15 pts)
    int timelinePoints = 0;
    if (investigation.playerTimeline.isNotEmpty) {
      final correctOrder =
          caseData.correctTimeline.map((e) => e.evidenceId).toSet().toList();
      final playerOrder = investigation.playerTimeline
          .where((id) => correctIds.contains(id))
          .toList();

      if (playerOrder.length >= 2) {
        // Count correctly ordered pairs
        int correctPairs = 0;
        int totalPairs = 0;
        for (int i = 0; i < playerOrder.length - 1; i++) {
          for (int j = i + 1; j < playerOrder.length; j++) {
            final ci = correctOrder.indexOf(playerOrder[i]);
            final cj = correctOrder.indexOf(playerOrder[j]);
            if (ci != -1 && cj != -1) {
              totalPairs++;
              if (ci < cj) correctPairs++;
            }
          }
        }
        if (totalPairs > 0) {
          timelinePoints = ((correctPairs / totalPairs) * 15).round();
        }
      }
    }

    // Chain of custody (5 pts)
    final custodyPoints = custody.allChecksPassed ? 5 : 0;

    final total = (suspectCorrect ? 30 : 0) +
        evidencePoints -
        falsePositivePenalty +
        timelinePoints +
        custodyPoints;

    return _ScoreResult(
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
}

class _ScoreResult {
  final bool suspectCorrect;
  final int correctEvidenceCount;
  final int evidencePoints;
  final int falsePositives;
  final int falsePositivePenalty;
  final int timelinePoints;
  final int custodyPoints;
  final int total;

  const _ScoreResult({
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
