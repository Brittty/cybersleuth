import 'package:cyber_sleuth/main.dart';
import 'package:cyber_sleuth/models/evidence_model.dart';
import 'package:cyber_sleuth/models/file_node_model.dart';
import 'package:cyber_sleuth/providers/chain_of_custody_provider.dart';
import 'package:cyber_sleuth/providers/contract_provider.dart';
import 'package:cyber_sleuth/providers/global_state_provider.dart';
import 'package:cyber_sleuth/providers/investigation_provider.dart';
import 'package:cyber_sleuth/providers/os_screen_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Iterable<FileNode> files(FileNode node) sync* {
  if (!node.isDirectory) yield node;
  for (final child in node.children) {
    yield* files(child);
  }
}

void main() {
  test(
    'Every answer timeline matches artifact timestamps and unique evidence',
    () {
      for (final contract in contracts) {
        final data = contract.caseData!;
        final timestamps = <String, DateTime>{};
        for (final disk in data.diskImages) {
          for (final file in files(disk.rootDirectory)) {
            if (file.lastModified.isNotEmpty) {
              timestamps[file.id] = DateTime.parse(file.lastModified);
            }
          }
          for (final record in disk.accessLogs) {
            timestamps[record.id] = DateTime.parse(record.timestamp);
          }
          for (final record in disk.emailRecords) {
            timestamps[record.id] = DateTime.parse(record.timestamp);
          }
          for (final record in disk.networkCaptures) {
            timestamps[record.id] = DateTime.parse(record.timestamp);
          }
        }
        final ids = data.correctTimeline
            .map((event) => event.evidenceId)
            .toList();
        expect(ids.toSet().length, ids.length);
        expect(
          ids,
          unorderedEquals(data.correctEvidence.map((item) => item.id)),
        );
        final times = <DateTime>[];
        for (final event in data.correctTimeline) {
          final time = DateTime.parse('${event.date} ${event.time}');
          expect(time, timestamps[event.evidenceId], reason: event.evidenceId);
          times.add(time);
        }
        expect(times, orderedEquals([...times]..sort()));
      }
      final data = contracts.first.caseData!;
      expect(data.correctTimeline.map((event) => event.evidenceId), [
        'priya_access_01',
        'priya_access_copy',
        'priya_file_01',
        'priya_net_03',
        'priya_email_03',
      ]);
      final disk = data.getDisk(data.suspectDiskId)!;
      expect(
        disk.accessLogs
            .firstWhere((entry) => entry.id == 'priya_access_copy')
            .action,
        'FILE_COPY',
      );
    },
  );

  test(
    'New case answers resolve to visible artifacts and chronological events',
    () {
      final allIds = <String>{};
      for (final contract in contracts.skip(1)) {
        final data = contract.caseData!;
        expect(data.diskImages, hasLength(3));
        expect(data.getDisk(data.suspectDiskId), isNotNull);
        final categories = <String, String>{};
        final timestamps = <String, String>{};
        for (final disk in data.diskImages) {
          expect(allIds.add(disk.diskId), isTrue);
          expect(disk.originalHash, matches(RegExp(r'^[a-f0-9]{64}$')));
          expect(files(disk.rootDirectory).length, greaterThanOrEqualTo(12));
          for (final file in files(disk.rootDirectory)) {
            expect(allIds.add(file.id), isTrue);
            expect(file.textContent, isNotEmpty);
            expect(file.hexPreview, isNotEmpty);
            categories[file.id] = 'file';
            timestamps[file.id] = file.lastModified;
          }
          for (final record in disk.accessLogs) {
            expect(allIds.add(record.id), isTrue);
            categories[record.id] = 'access_log';
            timestamps[record.id] = record.timestamp;
          }
          for (final record in disk.emailRecords) {
            expect(allIds.add(record.id), isTrue);
            categories[record.id] = 'email';
            timestamps[record.id] = record.timestamp;
          }
          for (final record in disk.networkCaptures) {
            expect(allIds.add(record.id), isTrue);
            categories[record.id] = 'network';
            timestamps[record.id] = record.timestamp;
          }
        }
        for (final evidence in data.correctEvidence) {
          expect(categories[evidence.id], evidence.category);
        }
        final times = <DateTime>[];
        for (final event in data.correctTimeline) {
          expect(
            data.correctEvidence.map((e) => e.id),
            contains(event.evidenceId),
          );
          expect(
            timestamps[event.evidenceId],
            '${event.date} ${event.time}:00',
          );
          times.add(DateTime.parse('${event.date} ${event.time}'));
        }
        expect(times, orderedEquals([...times]..sort()));
      }
    },
  );

  testWidgets('Select, investigate, score and switch between all cases', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final container = ProviderContainer(
      overrides: [cloneIntegrityRollProvider.overrideWithValue(() => 0.9)],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const MyApp()),
    );
    for (final contract in contracts) {
      await tester.tap(find.text(contract.sender));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Accept Contract'));
      await tester.pumpAndSettle();
      final data = contract.caseData!;
      expect(container.read(activeContractProvider).id, contract.id);
      expect(container.read(chainOfCustodyProvider).disks, data.diskImages);
      expect(container.read(investigationProvider).markedEvidence, isEmpty);
      expect(container.read(investigationProvider).playerSuspectDiskId, isNull);
      final navigation = container.read(globalStateProvider.notifier);
      navigation.setScreen(AppScreen.os);
      await tester.pumpAndSettle();
      expect(container.read(activeContractProvider).id, contract.id);
      final notepad = osToolsList.firstWhere((tool) => tool.name == 'Notepad');
      refTool() => container.read(osScreenProvider.notifier);
      refTool().setActiveTool(notepad);
      await tester.pumpAndSettle();
      final editor = find.byKey(const Key('notepad-editor'));
      expect(tester.widget<TextField>(editor).controller!.text, isEmpty);
      final notes = '${contract.id} notes\nCheck the transfer timestamp <3';
      await tester.enterText(editor, notes);
      refTool().setActiveTool(osToolsList.first);
      await tester.pumpAndSettle();
      refTool().setActiveTool(notepad);
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(editor).controller!.text, notes);
      container
          .read(investigationProvider.notifier)
          .selectDisk(data.diskImages.last.diskId);
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(editor).controller!.text, notes);
      expect(tester.takeException(), isNull);
      navigation.setScreen(AppScreen.report);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final investigation = container.read(investigationProvider.notifier);
      investigation.setSuspectDisk(data.suspectDiskId);
      for (final evidence in data.correctEvidence) {
        investigation.markEvidence(
          MarkedEvidence(
            id: evidence.id,
            diskId: data.suspectDiskId,
            category: evidence.category,
            title: evidence.title,
            description: evidence.explanation,
          ),
        );
      }
      investigation.setTimeline(
        data.correctTimeline.map((e) => e.evidenceId).toSet().toList(),
      );
      final custody = container.read(chainOfCustodyProvider.notifier);
      for (final disk in data.diskImages) {
        custody.inspectDisk(disk.diskId, true);
      }
      custody.signReceipt(examiner: 'Student Investigator');
      for (final disk in data.diskImages) {
        custody.computeHash(disk.diskId, disk.originalHash);
      }
      custody.beginVerification();
      for (final disk in data.diskImages) {
        custody.verifyHash(disk.diskId);
      }
      custody.enableWriteBlocker(true);
      for (final disk in data.diskImages) {
        custody.completeDiskClone(disk.diskId);
      }
      for (final disk in data.diskImages) {
        custody.verifyCloneHash(disk.diskId);
      }
      navigation.setScreen(AppScreen.scoring);
      await tester.pumpAndSettle();
      expect(find.text('100 / 100'), findsOneWidget);
      expect(
        find.text('Correctly identified ${data.suspectDiskId}'),
        findsOneWidget,
      );
      tester.view.physicalSize = const Size(375, 812);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Back to messages').hitTestable(), findsOneWidget);
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -1400),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Back to messages').hitTestable(), findsOneWidget);
      tester.view.physicalSize = const Size(1440, 1100);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Back to messages'));
      await tester.pumpAndSettle();
      expect(find.text('Messages'), findsOneWidget);
    }
  });
}
