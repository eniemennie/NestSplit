/// One line in the household activity feed.
class ActivityItem {
  const ActivityItem({
    required this.id,
    required this.memberId,
    required this.message,
    required this.timeLabel,
    required this.isToday,
  });

  final String id;
  final String memberId;

  /// Text after the member's name, e.g. "finished Mop".
  final String message;
  final String timeLabel;
  final bool isToday;
}
