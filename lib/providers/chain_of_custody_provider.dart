import 'package:cyber_sleuth/models/disk_image_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  final int currentDiskIndex;
  final List<DiskImage> disks;

  /// Tracks computed hashes per disk (diskId → hash string)
  final Map<String, String> computedHashes;

  /// Tracks whether hash was verified per disk
  final Map<String, bool> hashVerified;

  /// Tracks clone completion per disk
  final Map<String, bool> cloneComplete;

  /// Tracks clone hash verification per disk
  final Map<String, bool> cloneHashVerified;

  /// Whether the player has signed for receipt
  final bool receiptSigned;

  /// Whether all steps passed (for scoring bonus)
  final bool allChecksPassed;

  const ChainOfCustodyState({
    this.currentStep = CustodyStep.receive,
    this.currentDiskIndex = 0,
    this.disks = const [],
    this.computedHashes = const {},
    this.hashVerified = const {},
    this.cloneComplete = const {},
    this.cloneHashVerified = const {},
    this.receiptSigned = false,
    this.allChecksPassed = false,
  });

  ChainOfCustodyState copyWith({
    CustodyStep? currentStep,
    int? currentDiskIndex,
    List<DiskImage>? disks,
    Map<String, String>? computedHashes,
    Map<String, bool>? hashVerified,
    Map<String, bool>? cloneComplete,
    Map<String, bool>? cloneHashVerified,
    bool? receiptSigned,
    bool? allChecksPassed,
  }) {
    return ChainOfCustodyState(
      currentStep: currentStep ?? this.currentStep,
      currentDiskIndex: currentDiskIndex ?? this.currentDiskIndex,
      disks: disks ?? this.disks,
      computedHashes: computedHashes ?? this.computedHashes,
      hashVerified: hashVerified ?? this.hashVerified,
      cloneComplete: cloneComplete ?? this.cloneComplete,
      cloneHashVerified: cloneHashVerified ?? this.cloneHashVerified,
      receiptSigned: receiptSigned ?? this.receiptSigned,
      allChecksPassed: allChecksPassed ?? this.allChecksPassed,
    );
  }
}

class ChainOfCustodyNotifier extends Notifier<ChainOfCustodyState> {
  @override
  ChainOfCustodyState build() {
    return const ChainOfCustodyState();
  }

  void initializeWithDisks(List<DiskImage> disks) {
    state = ChainOfCustodyState(disks: disks);
  }

  void signReceipt() {
    state = state.copyWith(
      receiptSigned: true,
      currentStep: CustodyStep.computeHash,
    );
  }

  void computeHash(String diskId, String hash) {
    final updated = Map<String, String>.from(state.computedHashes);
    updated[diskId] = hash;
    state = state.copyWith(computedHashes: updated);
  }

  void verifyHash(String diskId) {
    final updated = Map<String, bool>.from(state.hashVerified);
    updated[diskId] = true;

    // Check if all disks verified → move to clone step
    final allVerified = state.disks.every((d) => updated[d.diskId] == true);
    state = state.copyWith(
      hashVerified: updated,
      currentStep: allVerified ? CustodyStep.cloneDrive : state.currentStep,
    );
  }

  void completeDiskClone(String diskId) {
    final updated = Map<String, bool>.from(state.cloneComplete);
    updated[diskId] = true;

    final allCloned = state.disks.every((d) => updated[d.diskId] == true);
    state = state.copyWith(
      cloneComplete: updated,
      currentStep: allCloned ? CustodyStep.verifyClone : state.currentStep,
    );
  }

  void verifyCloneHash(String diskId) {
    final updated = Map<String, bool>.from(state.cloneHashVerified);
    updated[diskId] = true;

    final allCloneVerified =
        state.disks.every((d) => updated[d.diskId] == true);
    state = state.copyWith(
      cloneHashVerified: updated,
      currentStep: allCloneVerified ? CustodyStep.complete : state.currentStep,
      allChecksPassed: allCloneVerified,
    );
  }

  void advanceDisk() {
    if (state.currentDiskIndex < state.disks.length - 1) {
      state = state.copyWith(currentDiskIndex: state.currentDiskIndex + 1);
    }
  }
}

final chainOfCustodyProvider =
    NotifierProvider<ChainOfCustodyNotifier, ChainOfCustodyState>(() {
  return ChainOfCustodyNotifier();
});
