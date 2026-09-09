import 'dart:math';

import 'package:cyber_sleuth/models/disk_image_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// A fresh roll is drawn for each valid imaging attempt, including retries.
final cloneIntegrityRollProvider = Provider<double Function()>((ref) {
  return Random().nextDouble;
});

enum CustodyStep {
  receive,
  computeHash,
  verifyHash,
  cloneDrive,
  verifyClone,
  complete,
}

class ChainOfCustodyState {
  final CustodyStep currentStep;
  final List<DiskImage> disks;
  final Set<String> inspectedDisks;
  final String examiner;
  final bool writeBlockerEnabled;
  final Map<String, String> computedHashes;
  final Map<String, bool> hashVerified;
  final Map<String, bool> cloneComplete;
  final Map<String, String> cloneHashes;
  final Map<String, bool> cloneHashVerified;
  final Set<String> rejectedClones;
  final List<String> activityLog;
  final bool receiptSigned;
  final bool allChecksPassed;

  const ChainOfCustodyState({
    this.currentStep = CustodyStep.receive,
    this.disks = const [],
    this.inspectedDisks = const {},
    this.examiner = '',
    this.writeBlockerEnabled = false,
    this.computedHashes = const {},
    this.hashVerified = const {},
    this.cloneComplete = const {},
    this.cloneHashes = const {},
    this.cloneHashVerified = const {},
    this.rejectedClones = const {},
    this.activityLog = const [],
    this.receiptSigned = false,
    this.allChecksPassed = false,
  });

  ChainOfCustodyState copyWith({
    CustodyStep? currentStep,
    Set<String>? inspectedDisks,
    String? examiner,
    bool? writeBlockerEnabled,
    Map<String, String>? computedHashes,
    Map<String, bool>? hashVerified,
    Map<String, bool>? cloneComplete,
    Map<String, String>? cloneHashes,
    Map<String, bool>? cloneHashVerified,
    Set<String>? rejectedClones,
    List<String>? activityLog,
    bool? receiptSigned,
    bool? allChecksPassed,
  }) => ChainOfCustodyState(
    currentStep: currentStep ?? this.currentStep,
    disks: disks,
    inspectedDisks: inspectedDisks ?? this.inspectedDisks,
    examiner: examiner ?? this.examiner,
    writeBlockerEnabled: writeBlockerEnabled ?? this.writeBlockerEnabled,
    computedHashes: computedHashes ?? this.computedHashes,
    hashVerified: hashVerified ?? this.hashVerified,
    cloneComplete: cloneComplete ?? this.cloneComplete,
    cloneHashes: cloneHashes ?? this.cloneHashes,
    cloneHashVerified: cloneHashVerified ?? this.cloneHashVerified,
    rejectedClones: rejectedClones ?? this.rejectedClones,
    activityLog: activityLog ?? this.activityLog,
    receiptSigned: receiptSigned ?? this.receiptSigned,
    allChecksPassed: allChecksPassed ?? this.allChecksPassed,
  );
}

class ChainOfCustodyNotifier extends Notifier<ChainOfCustodyState> {
  @override
  ChainOfCustodyState build() => const ChainOfCustodyState();

  void initializeWithDisks(List<DiskImage> disks) {
    state = ChainOfCustodyState(disks: disks);
  }

  bool _known(String id) => state.disks.any((disk) => disk.diskId == id);
  bool _all(Map<String, bool> values) =>
      state.disks.isNotEmpty &&
      state.disks.every((disk) => values[disk.diskId] == true);
  void _record(String message) {
    final time = DateTime.now().toIso8601String().substring(11, 19);
    state = state.copyWith(
      activityLog: [...state.activityLog, '[$time] $message'],
    );
  }

  void inspectDisk(String id, bool checked) {
    if (state.currentStep != CustodyStep.receive || !_known(id)) return;
    final inspected = {...state.inspectedDisks};
    checked ? inspected.add(id) : inspected.remove(id);
    state = state.copyWith(inspectedDisks: inspected);
  }

  bool signReceipt({required String examiner}) {
    if (state.currentStep != CustodyStep.receive ||
        examiner.trim().isEmpty ||
        state.disks.isEmpty ||
        state.inspectedDisks.length != state.disks.length) {
      return false;
    }
    state = state.copyWith(
      examiner: examiner.trim(),
      receiptSigned: true,
      currentStep: CustodyStep.computeHash,
    );
    _record(
      '${state.examiner} accepted ${state.disks.length} disks; labels and seals checked.',
    );
    return true;
  }

  void enableWriteBlocker(bool enabled) {
    if (state.currentStep != CustodyStep.cloneDrive) return;
    state = state.copyWith(writeBlockerEnabled: enabled);
    _record(
      enabled
          ? 'Write blocker enabled; originals protected.'
          : 'Write blocker disabled.',
    );
  }

  bool computeHash(String diskId, String hash) {
    if (state.currentStep != CustodyStep.computeHash ||
        !_known(diskId) ||
        state.computedHashes.containsKey(diskId)) {
      return false;
    }
    state = state.copyWith(
      computedHashes: {...state.computedHashes, diskId: hash},
    );
    _record('$diskId: original hash computed.');
    return true;
  }

  bool beginVerification() {
    if (state.currentStep != CustodyStep.computeHash ||
        state.disks.isEmpty ||
        state.computedHashes.length != state.disks.length) {
      return false;
    }
    state = state.copyWith(currentStep: CustodyStep.verifyHash);
    return true;
  }

  bool verifyHash(String diskId, {bool matches = true}) {
    if (state.currentStep != CustodyStep.verifyHash ||
        !_known(diskId) ||
        state.hashVerified[diskId] == true) {
      return false;
    }
    final disk = state.disks.firstWhere((d) => d.diskId == diskId);
    final actualMatch = state.computedHashes[diskId] == disk.originalHash;
    if (matches != actualMatch) {
      _record('$diskId: incorrect original comparison; review both values.');
      return false;
    }
    if (!actualMatch) {
      // An original mismatch requires a new intake, never a verified flag.
      _record(
        '$diskId: original mismatch; processing stopped. Request a new acquisition.',
      );
      return false;
    }
    final verified = {...state.hashVerified, diskId: true};
    state = state.copyWith(
      hashVerified: verified,
      currentStep: _all(verified) ? CustodyStep.cloneDrive : state.currentStep,
    );
    _record('$diskId: original matches the intake manifest.');
    return true;
  }

  bool completeDiskClone(String diskId) {
    final initial = state.currentStep == CustodyStep.cloneDrive;
    final retry =
        state.currentStep == CustodyStep.verifyClone &&
        state.rejectedClones.contains(diskId);
    if ((!initial && !retry) ||
        !_known(diskId) ||
        !state.writeBlockerEnabled ||
        state.hashVerified[diskId] != true ||
        (initial && state.cloneComplete[diskId] == true)) {
      return false;
    }
    final original = state.computedHashes[diskId]!;
    final damaged = ref.read(cloneIntegrityRollProvider)() < 0.2;
    final hash = damaged
        ? '${original[0] == '0' ? '1' : '0'}${original.substring(1)}'
        : original;
    final complete = {...state.cloneComplete, diskId: true};
    state = state.copyWith(
      cloneComplete: complete,
      cloneHashes: {...state.cloneHashes, diskId: hash},
      rejectedClones: {...state.rejectedClones}..remove(diskId),
      currentStep: _all(complete) ? CustodyStep.verifyClone : state.currentStep,
    );
    _record(
      '$diskId: ${retry ? 'replacement' : 'working'} image created with write protection.',
    );
    return true;
  }

  bool verifyCloneHash(String diskId, {bool matches = true}) {
    if (state.currentStep != CustodyStep.verifyClone ||
        !_known(diskId) ||
        state.cloneComplete[diskId] != true ||
        state.cloneHashVerified[diskId] == true ||
        state.rejectedClones.contains(diskId)) {
      return false;
    }
    final actualMatch =
        state.cloneHashes[diskId] == state.computedHashes[diskId];
    if (matches != actualMatch) {
      _record('$diskId: incorrect clone comparison; review both values.');
      return false;
    }
    if (!actualMatch) {
      state = state.copyWith(rejectedClones: {...state.rejectedClones, diskId});
      _record(
        '$diskId: damaged clone rejected; create a replacement before investigation.',
      );
      return true;
    }
    final verified = {...state.cloneHashVerified, diskId: true};
    final complete = _all(verified);
    state = state.copyWith(
      cloneHashVerified: verified,
      currentStep: complete ? CustodyStep.complete : state.currentStep,
      allChecksPassed:
          complete && state.receiptSigned && _all(state.hashVerified),
    );
    _record('$diskId: clone integrity verified.');
    return true;
  }
}

final chainOfCustodyProvider =
    NotifierProvider<ChainOfCustodyNotifier, ChainOfCustodyState>(
      ChainOfCustodyNotifier.new,
    );
