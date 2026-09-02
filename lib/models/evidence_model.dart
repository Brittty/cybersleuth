/// Represents a ground-truth evidence item — used for scoring
/// the player's findings against the correct answer.
class CorrectEvidence {
  final String id;
  final String category;
  final String title;
  final String explanation;

  const CorrectEvidence({
    required this.id,
    required this.category,
    required this.title,
    required this.explanation,
  });
}

/// A single event in the correct incident timeline.
class TimelineEvent {
  final String date;
  final String time;
  final String description;
  final String evidenceId;

  const TimelineEvent({
    required this.date,
    required this.time,
    required this.description,
    required this.evidenceId,
  });
}

/// Tracks an item the player has marked as evidence during investigation.
class MarkedEvidence {
  final String id;
  final String diskId;
  final String category;
  final String title;
  final String description;

  const MarkedEvidence({
    required this.id,
    required this.diskId,
    required this.category,
    required this.title,
    required this.description,
  });
}
