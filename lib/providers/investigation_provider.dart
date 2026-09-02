import 'package:cyber_sleuth/models/evidence_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InvestigationState {
  /// Currently selected disk ID for viewing
  final String? selectedDiskId;

  /// Evidence items the player has marked during investigation
  final List<MarkedEvidence> markedEvidence;

  /// Player's timeline arrangement (ordered list of marked evidence IDs)
  final List<String> playerTimeline;

  /// Player's selected suspect disk ID (for the report)
  final String? playerSuspectDiskId;

  const InvestigationState({
    this.selectedDiskId,
    this.markedEvidence = const [],
    this.playerTimeline = const [],
    this.playerSuspectDiskId,
  });

  InvestigationState copyWith({
    String? selectedDiskId,
    List<MarkedEvidence>? markedEvidence,
    List<String>? playerTimeline,
    String? playerSuspectDiskId,
  }) {
    return InvestigationState(
      selectedDiskId: selectedDiskId ?? this.selectedDiskId,
      markedEvidence: markedEvidence ?? this.markedEvidence,
      playerTimeline: playerTimeline ?? this.playerTimeline,
      playerSuspectDiskId: playerSuspectDiskId ?? this.playerSuspectDiskId,
    );
  }

  bool isMarked(String evidenceId) {
    return markedEvidence.any((e) => e.id == evidenceId);
  }
}

class InvestigationNotifier extends Notifier<InvestigationState> {
  @override
  InvestigationState build() {
    return const InvestigationState();
  }

  void selectDisk(String diskId) {
    state = state.copyWith(selectedDiskId: diskId);
  }

  void markEvidence(MarkedEvidence evidence) {
    if (state.isMarked(evidence.id)) return;
    final updated = [...state.markedEvidence, evidence];
    state = state.copyWith(markedEvidence: updated);
  }

  void unmarkEvidence(String evidenceId) {
    final updated =
        state.markedEvidence.where((e) => e.id != evidenceId).toList();
    final updatedTimeline =
        state.playerTimeline.where((id) => id != evidenceId).toList();
    state = state.copyWith(
        markedEvidence: updated, playerTimeline: updatedTimeline);
  }

  void toggleEvidence(MarkedEvidence evidence) {
    if (state.isMarked(evidence.id)) {
      unmarkEvidence(evidence.id);
    } else {
      markEvidence(evidence);
    }
  }

  void setSuspectDisk(String diskId) {
    state = state.copyWith(playerSuspectDiskId: diskId);
  }

  void setTimeline(List<String> orderedIds) {
    state = state.copyWith(playerTimeline: orderedIds);
  }

  void addToTimeline(String evidenceId) {
    if (state.playerTimeline.contains(evidenceId)) return;
    state = state.copyWith(
        playerTimeline: [...state.playerTimeline, evidenceId]);
  }

  void removeFromTimeline(String evidenceId) {
    state = state.copyWith(
        playerTimeline:
            state.playerTimeline.where((id) => id != evidenceId).toList());
  }

  void reorderTimeline(int oldIndex, int newIndex) {
    final list = [...state.playerTimeline];
    if (newIndex > oldIndex) newIndex--;
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    state = state.copyWith(playerTimeline: list);
  }
}

final investigationProvider =
    NotifierProvider<InvestigationNotifier, InvestigationState>(() {
  return InvestigationNotifier();
});
