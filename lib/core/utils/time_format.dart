/// Tiny date helpers so the app needs no intl package.
class TimeFormat {
  TimeFormat._();

  static const List<String> _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  /// "Wed 6:20 PM"
  static String dayAndTime(DateTime t) {
    final hour12 = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final minute = t.minute.toString().padLeft(2, '0');
    final suffix = t.hour >= 12 ? 'PM' : 'AM';
    return '${_weekdays[t.weekday - 1]} $hour12:$minute $suffix';
  }

  /// ISO week number of the year (1 to 53).
  static int isoWeek(DateTime date) {
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays + 1;
    final week = (dayOfYear - date.weekday + 10) ~/ 7;
    if (week < 1) return 52;
    if (week > 53) return 53;
    return week;
  }
}
