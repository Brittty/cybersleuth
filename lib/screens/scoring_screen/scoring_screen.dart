import 'package:cyber_sleuth/providers/global_state_provider.dart';
import 'package:cyber_sleuth/providers/contract_provider.dart';
import 'package:cyber_sleuth/models/investigation_score.dart';
import 'package:cyber_sleuth/providers/chain_of_custody_provider.dart';
import 'package:cyber_sleuth/providers/investigation_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScoringScreen extends ConsumerWidget {
  const ScoringScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final investigation = ref.watch(investigationProvider);
    final custody = ref.watch(chainOfCustodyProvider);
    final contract = ref.watch(activeContractProvider);
    final data = contract.caseData!;
    final score = calculateInvestigationScore(investigation, custody, data);
    final assessment = score.total >= 85
        ? 'High accuracy'
        : score.total >= 60
        ? 'Satisfactory'
        : score.total >= 30
        ? 'Needs improvement'
        : 'Case unresolved';

    final breakdown = _panel(context, 'Assessment', [
      _scoreRow(
        context,
        'Device identification',
        score.suspectCorrect
            ? 'Correctly identified ${data.suspectDiskId}'
            : 'Expected device: ${data.suspectDiskId}',
        '${score.suspectCorrect ? 30 : 0} / 30',
      ),
      _scoreRow(
        context,
        'Key evidence',
        '${score.correctEvidenceCount} of ${data.correctEvidence.length} items identified',
        '${score.evidencePoints} / 50',
      ),
      _scoreRow(
        context,
        'Timeline completeness and order',
        score.timelinePoints == 15
            ? 'Submitted events are in the correct order'
            : score.timelinePoints > 0
            ? 'The sequence is incomplete or contains ordering errors'
            : 'No correct sequence established',
        '${score.timelinePoints} / 15',
      ),
      _scoreRow(
        context,
        'Chain of custody',
        score.custodyPoints == 5
            ? 'All integrity checks completed'
            : 'Integrity checks incomplete',
        '${score.custodyPoints} / 5',
      ),
      _scoreRow(
        context,
        'Supporting evidence',
        'Relevant context; no bonus or penalty',
        '${investigation.markedEvidence.map((item) => item.id).toSet().intersection(data.supportingEvidenceIds).length} items',
      ),
      _scoreRow(
        context,
        'False positives',
        '${score.falsePositives} unrelated items marked',
        score.falsePositivePenalty == 0
            ? '0 pts'
            : '−${score.falsePositivePenalty} pts',
        penalty: score.falsePositivePenalty > 0,
      ),
    ]);
    final evidence = _panel(context, 'Evidence review', [
      for (final item in data.correctEvidence)
        _evidenceRow(
          context,
          item.title,
          item.explanation,
          investigation.isMarked(item.id),
        ),
    ]);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest,
                border: Border(bottom: BorderSide(color: colors.outline)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    size: 20,
                    color: colors.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Investigation Results',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(
                  MediaQuery.sizeOf(context).width < 600 ? 16 : 32,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CASE / ${contract.id}',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          contract.sender,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            border: Border.all(color: colors.outline),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Wrap(
                            spacing: 32,
                            runSpacing: 16,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Final score',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${score.total} / 100',
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 30,
                                      fontWeight: FontWeight.w600,
                                      color: colors.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    assessment,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Assessment based on submitted evidence.',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            if (constraints.maxWidth < 850) {
                              return Column(
                                children: [
                                  breakdown,
                                  const SizedBox(height: 20),
                                  evidence,
                                ],
                              );
                            }
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 5, child: breakdown),
                                const SizedBox(width: 24),
                                Expanded(flex: 6, child: evidence),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: colors.surface,
                border: Border(top: BorderSide(color: colors.outline)),
              ),
              child: Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: () => ref
                      .read(globalStateProvider.notifier)
                      .setScreen(AppScreen.messaging),
                  icon: const Icon(Icons.mail_outline, size: 18),
                  label: const Text('Back to messages'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _panel(BuildContext context, String title, List<Widget> rows) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: colors.surfaceContainerHighest,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          for (final row in rows) ...[const Divider(height: 1), row],
        ],
      ),
    );
  }

  Widget _scoreRow(
    BuildContext context,
    String title,
    String detail,
    String points, {
    bool penalty = false,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(detail, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            points,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: penalty
                  ? theme.colorScheme.error
                  : theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _evidenceRow(
    BuildContext context,
    String title,
    String explanation,
    bool found,
  ) {
    final theme = Theme.of(context);
    final statusColor = found
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                found ? Icons.check : Icons.remove,
                size: 16,
                color: statusColor,
              ),
              const SizedBox(width: 6),
              Text(
                found ? 'Identified' : 'Not identified',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            explanation,
            style: theme.textTheme.bodySmall?.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }
}
