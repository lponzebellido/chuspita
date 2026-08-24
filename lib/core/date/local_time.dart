final class LocalTime implements Comparable<LocalTime> {
  factory LocalTime({required int hour, required int minute}) {
    if (hour < 0 || hour > 23) {
      throw ArgumentError.value(hour, 'hour', 'Hour must be between 0 and 23');
    }

    if (minute < 0 || minute > 59) {
      throw ArgumentError.value(
        minute,
        'minute',
        'Minute must be between 0 and 59',
      );
    }

    return LocalTime._(hour: hour, minute: minute);
  }

  factory LocalTime.fromMinutesSinceMidnight(int value) {
    if (value < 0 || value >= minutesPerDay) {
      throw ArgumentError.value(
        value,
        'value',
        'Minutes since midnight must be between 0 and 1439',
      );
    }

    return LocalTime(hour: value ~/ 60, minute: value % 60);
  }

  const LocalTime._({required this.hour, required this.minute});

  static const int minutesPerDay = 24 * 60;
  static const LocalTime midnight = LocalTime._(hour: 0, minute: 0);

  final int hour;
  final int minute;

  int get minutesSinceMidnight => hour * 60 + minute;

  @override
  int compareTo(LocalTime other) {
    return minutesSinceMidnight.compareTo(other.minutesSinceMidnight);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is LocalTime && hour == other.hour && minute == other.minute;
  }

  @override
  int get hashCode => Object.hash(hour, minute);

  @override
  String toString() {
    return '${hour.toString().padLeft(2, '0')}:'
        '${minute.toString().padLeft(2, '0')}';
  }
}
