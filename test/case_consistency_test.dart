import 'package:cyber_sleuth/models/evidence_model.dart';
import 'package:cyber_sleuth/models/investigation_score.dart';
import 'package:cyber_sleuth/models/file_node_model.dart';
import 'package:cyber_sleuth/providers/contract_provider.dart';
import 'package:cyber_sleuth/providers/investigation_provider.dart';
import 'package:cyber_sleuth/providers/chain_of_custody_provider.dart';
import 'package:flutter_test/flutter_test.dart';

Iterable<FileNode> allFiles(FileNode node) sync* {
  if (!node.isDirectory) yield node;
  for (final child in node.children) {
    yield* allFiles(child);
  }
}

MarkedEvidence mark(String id) => MarkedEvidence(
  id: id,
  diskId: '',
  category: '',
  title: '',
  description: '',
);

void main() {
  for (final contract in contracts) {
    final data = contract.caseData!;
    final ordered = data.correctTimeline
        .map((event) => event.evidenceId)
        .toList();
    InvestigationScore score(List<String> timeline, {List<String>? marked}) =>
        calculateInvestigationScore(
          InvestigationState(
            playerTimeline: timeline,
            markedEvidence: (marked ?? ordered).map(mark).toList(),
          ),
          const ChainOfCustodyState(),
          data,
        );

    test(
      '${contract.id}: timeline completeness, order and marked evidence',
      () {
        expect(score(ordered).timelinePoints, 15);
        expect(score(ordered.take(2).toList()).timelinePoints, 2);
        expect(score(ordered.take(4).toList()).timelinePoints, 9);
        expect(score(ordered.reversed.toList()).timelinePoints, 0);
        expect(score([]).timelinePoints, 0);
        expect(score([ordered.first]).timelinePoints, 0);
        expect(score([...ordered, ...ordered]).timelinePoints, 15);
        expect(score(ordered, marked: []).timelinePoints, 0);
        final swapped = [...ordered];
        swapped[0] = ordered[1];
        swapped[1] = ordered[0];
        expect(score(swapped).timelinePoints, 14);
      },
    );

    test(
      '${contract.id}: supporting evidence resolves and is not penalized',
      () {
        final artifactIds = <String>{};
        for (final disk in data.diskImages) {
          artifactIds.addAll(
            allFiles(disk.rootDirectory).map((file) => file.id),
          );
          artifactIds.addAll(disk.accessLogs.map((record) => record.id));
          artifactIds.addAll(disk.emailRecords.map((record) => record.id));
          artifactIds.addAll(disk.networkCaptures.map((record) => record.id));
        }
        expect(data.supportingEvidenceIds.difference(artifactIds), isEmpty);
        expect(
          data.supportingEvidenceIds.intersection(ordered.toSet()),
          isEmpty,
        );
        final result = score(
          ordered,
          marked: [...ordered, ...data.supportingEvidenceIds],
        );
        expect(result.falsePositives, 0);
        expect(result.evidencePoints, 50);
        expect(
          score(
            ordered,
            marked: [...ordered, 'unrelated'],
          ).falsePositivePenalty,
          5,
        );
      },
    );

    test('${contract.id}: email domain classification', () {
      final domain = data.internalEmailDomains.single;
      expect(data.isInternalEmail('MANAGER@${domain.toUpperCase()} '), isTrue);
      expect(data.isInternalEmail('manager@$domain.attacker.example'), isFalse);
      expect(data.isInternalEmail('manager@not$domain'), isFalse);
      expect(data.isInternalEmail('recruiting@talent-market.example'), isFalse);
    });
  }

  test(
    'New cases separate backup approval from completion and vary file dates',
    () {
      for (final contract in contracts.skip(1)) {
        final disks = contract.caseData!.diskImages;
        final approval = disks[1].emailRecords.first;
        expect(approval.body, contains('then perform a restore check'));
        expect(approval.body, isNot(contains('restore check passed')));
        final files = disks
            .expand((disk) => allFiles(disk.rootDirectory))
            .toList();
        final receipt = files.firstWhere(
          (file) => file.name == 'backup_receipt.txt',
        );
        expect(
          DateTime.parse(approval.timestamp)
              .isBefore(DateTime.parse(receipt.lastModified)),
          isTrue,
        );
        expect(
          files.map((file) => file.lastModified).toSet().length,
          greaterThan(10),
        );
        final update = files.firstWhere(
          (file) => file.name == 'update_history.log',
        );
        expect(update.lastModified, endsWith('07:31:00'));
        final restore = files.firstWhere(
          (file) => file.name == 'restore_test.txt',
        );
        expect(restore.lastModified, endsWith('09:08:00'));
      }
      expect(
        contracts[2].caseData!.diskImages.first.emailRecords.first.body,
        contains('this morning'),
      );
    },
  );
}
