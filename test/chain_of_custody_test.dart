import 'package:cyber_sleuth/main.dart';
import 'package:cyber_sleuth/providers/chain_of_custody_provider.dart';
import 'package:cyber_sleuth/providers/contract_provider.dart';
import 'package:cyber_sleuth/providers/global_state_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Each disk and retry receives an independent integrity roll', () {
    final rolls = [0.1, 0.2, 0.0, 0.05, 0.9].iterator;
    var rollCount = 0;
    final container = ProviderContainer(
      overrides: [
        cloneIntegrityRollProvider.overrideWithValue(() {
          rollCount++;
          expect(rolls.moveNext(), isTrue);
          return rolls.current;
        }),
      ],
    );
    addTearDown(container.dispose);
    final notifier = container.read(chainOfCustodyProvider.notifier);
    final disks = contracts[1].caseData!.diskImages;
    notifier.initializeWithDisks(disks);
    expect(notifier.completeDiskClone(disks.first.diskId), isFalse);
    expect(rollCount, 0);
    for (final disk in disks) {
      notifier.inspectDisk(disk.diskId, true);
    }
    notifier.signReceipt(examiner: 'Examiner');
    for (final disk in disks) {
      notifier.computeHash(disk.diskId, disk.originalHash);
    }
    notifier.beginVerification();
    for (final disk in disks) {
      notifier.verifyHash(disk.diskId);
    }
    notifier.enableWriteBlocker(true);
    for (final disk in disks) {
      notifier.completeDiskClone(disk.diskId);
    }
    final state = container.read(chainOfCustodyProvider);
    expect(state.cloneHashes[disks[0].diskId], isNot(disks[0].originalHash));
    expect(state.cloneHashes[disks[1].diskId], disks[1].originalHash);
    expect(state.cloneHashes[disks[2].diskId], isNot(disks[2].originalHash));
    final id = disks.first.diskId;
    expect(notifier.verifyCloneHash(id), isFalse);
    notifier.verifyCloneHash(id, matches: false);
    notifier.completeDiskClone(id);
    expect(notifier.verifyCloneHash(id), isFalse);
    notifier.verifyCloneHash(id, matches: false);
    notifier.completeDiskClone(id);
    expect(notifier.verifyCloneHash(id), isTrue);
    expect(rollCount, 5);
    expect(container.read(chainOfCustodyProvider).allChecksPassed, isFalse);
  });

  testWidgets(
    'Debug skip opens the active case without awarding custody checks',
    (tester) async {
      tester.view.physicalSize = const Size(1440, 1100);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final navigation = container.read(globalStateProvider.notifier);
      navigation.setActiveContractId(contracts[1].id);
      navigation.setScreen(AppScreen.chainOfCustody);
      await tester.pumpWidget(
        UncontrolledProviderScope(container: container, child: const MyApp()),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('debug-skip-custody')));
      await tester.pumpAndSettle();
      expect(container.read(globalStateProvider).currentScreen, AppScreen.os);
      expect(container.read(activeContractProvider).id, contracts[1].id);
      expect(container.read(chainOfCustodyProvider).allChecksPassed, isFalse);
      expect(tester.takeException(), isNull);
    },
  );

  test('Custody rejects skipped steps and mismatched originals', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(chainOfCustodyProvider.notifier);
    final disk = contracts[1].caseData!.diskImages.first;
    notifier.initializeWithDisks([disk]);
    expect(notifier.signReceipt(examiner: 'Student'), isFalse);
    expect(notifier.computeHash(disk.diskId, disk.originalHash), isFalse);
    expect(notifier.verifyCloneHash(disk.diskId), isFalse);
    notifier.inspectDisk('unknown', true);
    expect(container.read(chainOfCustodyProvider).inspectedDisks, isEmpty);
    notifier.inspectDisk(disk.diskId, true);
    expect(notifier.signReceipt(examiner: '  '), isFalse);
    expect(notifier.signReceipt(examiner: 'Student'), isTrue);
    expect(notifier.beginVerification(), isFalse);
    expect(notifier.completeDiskClone(disk.diskId), isFalse);
    notifier.computeHash(disk.diskId, 'damaged-image-hash');
    notifier.beginVerification();
    expect(notifier.verifyHash(disk.diskId), isFalse);
    expect(notifier.verifyHash(disk.diskId, matches: false), isFalse);
    expect(container.read(chainOfCustodyProvider).hashVerified, isEmpty);
    expect(
      container.read(chainOfCustodyProvider).currentStep,
      CustodyStep.verifyHash,
    );
    expect(container.read(chainOfCustodyProvider).allChecksPassed, isFalse);
  });

  testWidgets('Student completes intake, rejects damaged clone and recovers', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1100, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var imagingAttempts = 0;
    final container = ProviderContainer(
      overrides: [
        cloneIntegrityRollProvider.overrideWithValue(
          () => imagingAttempts++ == 0 ? 0.1 : 0.9,
        ),
      ],
    );
    addTearDown(container.dispose);
    final disk = contracts[1].caseData!.diskImages.first;
    container
        .read(globalStateProvider.notifier)
        .setActiveContractId(contracts[1].id);
    container
        .read(globalStateProvider.notifier)
        .setScreen(AppScreen.chainOfCustody);
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const MyApp()),
    );
    await tester.pumpAndSettle();
    // One disk keeps this focused interaction test short; the catalog test covers all three.
    container.read(chainOfCustodyProvider.notifier).initializeWithDisks([disk]);
    await tester.pumpAndSettle();
    Future<void> tap(String key) async {
      final finder = find.byKey(Key(key));
      await tester.ensureVisible(finder);
      await tester.tap(finder);
      await tester.pumpAndSettle();
    }

    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('sign-receipt')))
          .onPressed,
      isNull,
    );
    await tester.enterText(find.byType(TextField), 'Student Investigator');
    await tap('inspect-${disk.diskId}');
    await tap('sign-receipt');
    await tap('compute-${disk.diskId}');
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    await tap('begin-verification');
    expect(
      container.read(chainOfCustodyProvider).currentStep,
      CustodyStep.verifyHash,
    );
    await tap('original-${disk.diskId}-false');
    expect(container.read(chainOfCustodyProvider).hashVerified, isEmpty);
    await tap('original-${disk.diskId}-true');
    expect(
      tester
          .widget<FilledButton>(find.byKey(Key('copy-${disk.diskId}')))
          .onPressed,
      isNull,
    );
    await tap('write-blocker');
    await tap('copy-${disk.diskId}');
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    await tap('clone-${disk.diskId}-true');
    expect(container.read(chainOfCustodyProvider).cloneHashVerified, isEmpty);
    await tap('clone-${disk.diskId}-false');
    expect(
      container.read(chainOfCustodyProvider).rejectedClones,
      contains(disk.diskId),
    );
    expect(find.byKey(const Key('begin-investigation')), findsNothing);
    await tap('retry-${disk.diskId}');
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    await tap('clone-${disk.diskId}-true');
    final state = container.read(chainOfCustodyProvider);
    expect(state.currentStep, CustodyStep.complete);
    expect(state.allChecksPassed, isTrue);
    expect(state.activityLog.join('\n'), contains('damaged clone rejected'));
    expect(state.activityLog.join('\n'), contains('replacement'));
    expect(tester.takeException(), isNull);
    final log = find.byKey(const PageStorageKey('custody-log'));
    await tester.ensureVisible(log);
    await tester.tap(
      find.text('Custody activity log (${state.activityLog.length})'),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text(state.activityLog.last), findsOneWidget);
    await tester.ensureVisible(find.text(state.activityLog.last));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    for (var i = 0; i < 2; i++) {
      final title = find.text(
        'Custody activity log (${state.activityLog.length})',
      );
      await tester.ensureVisible(title);
      await tester.tap(title);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
    expect(find.text(state.activityLog.last), findsOneWidget);
    // The existing forensic desktop is designed for a wider viewport.
    tester.view.physicalSize = const Size(1440, 1100);
    await tester.pumpAndSettle();
    await tap('begin-investigation');
    expect(container.read(globalStateProvider).currentScreen, AppScreen.os);
    expect(tester.takeException(), isNull);
    container.read(chainOfCustodyProvider.notifier).initializeWithDisks([disk]);
    expect(container.read(chainOfCustodyProvider).activityLog, isEmpty);
    expect(container.read(chainOfCustodyProvider).writeBlockerEnabled, isFalse);
  });
}
