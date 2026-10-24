enum ChoreStatus { todo, done, overdue }

enum Difficulty { light, medium, heavy }

enum Frequency { daily, weekly, twiceAWeek }

/// One chore assigned to one member for the current week.
class Chore {
  const Chore({
    required this.id,
    required this.name,
    required this.assigneeId,
    required this.day,
    required this.dueFull,
    required this.status,
    required this.iconKey,
    this.difficulty = Difficulty.medium,
    this.frequency = Frequency.weekly,
    this.completedAt,
  });

  final String id;
  final String name;
  final String assigneeId;

  /// Short label shown in lists, e.g. "Mon" or "Today".
  final String day;

  /// Long label shown on the detail screen, e.g. "Wednesday".
  final String dueFull;
  final ChoreStatus status;

  /// Key resolved to an icon in features/chores/chore_icons.dart (keeps data free of UI types).
  final String iconKey;
  final Difficulty difficulty;
  final Frequency frequency;
  final DateTime? completedAt;

  bool get isDone => status == ChoreStatus.done;

  Chore copyWith({String? assigneeId, ChoreStatus? status, DateTime? completedAt}) {
    return Chore(
      id: id,
      name: name,
      assigneeId: assigneeId ?? this.assigneeId,
      day: day,
      dueFull: dueFull,
      status: status ?? this.status,
      iconKey: iconKey,
      difficulty: difficulty,
      frequency: frequency,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
