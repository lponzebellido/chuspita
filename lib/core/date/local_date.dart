final class LocalDate implements Comparable<LocalDate> {
  static final _isoPattern = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');

  factory LocalDate({required int year, required int month, required int day}) {
    if (year < 1 || year > 9999) {
      throw ArgumentError.value(
        year,
        'year',
        'Year must be between 1 and 9999',
      );
    }

    final date = DateTime.utc(year, month, day);

    if (date.year != year || date.month != month || date.day != day) {
      throw ArgumentError('Invalid local date: $year-$month-$day');
    }

    return LocalDate._(year: year, month: month, day: day);
  }

  factory LocalDate.parse(String value) {
    final match = _isoPattern.firstMatch(value);

    if (match == null) {
      throw ArgumentError.value(
        value,
        'value',
        'Local date must use the YYYY-MM-DD format',
      );
    }

    return LocalDate(
      year: int.parse(match.group(1)!),
      month: int.parse(match.group(2)!),
      day: int.parse(match.group(3)!),
    );
  }

  const LocalDate._({
    required this.year,
    required this.month,
    required this.day,
  });

  final int year;
  final int month;
  final int day;

  @override
  int compareTo(LocalDate other) {
    final yearComparison = year.compareTo(other.year);

    if (yearComparison != 0) {
      return yearComparison;
    }

    final monthComparison = month.compareTo(other.month);

    if (monthComparison != 0) {
      return monthComparison;
    }

    return day.compareTo(other.day);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is LocalDate &&
            year == other.year &&
            month == other.month &&
            day == other.day;
  }

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() {
    final paddedYear = year.toString().padLeft(4, '0');
    final paddedMonth = month.toString().padLeft(2, '0');
    final paddedDay = day.toString().padLeft(2, '0');

    return '$paddedYear-$paddedMonth-$paddedDay';
  }
}
