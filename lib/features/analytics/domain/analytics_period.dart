import 'package:chuspita/core/date/local_date.dart';

enum AnalyticsPeriod { day, week, month, year, custom }

typedef AnalyticsDateRange = ({LocalDate startDate, LocalDate endDate});

AnalyticsDateRange previousEquivalentPeriod({
  required AnalyticsPeriod period,
  required LocalDate startDate,
  required LocalDate endDate,
}) {
  if (startDate.compareTo(endDate) > 0) {
    throw ArgumentError('The start date cannot be after the end date');
  }

  final start = _toDateTime(startDate);
  final end = _toDateTime(endDate);

  return switch (period) {
    AnalyticsPeriod.day => _shiftRange(start, end, const Duration(days: 1)),
    AnalyticsPeriod.week => _shiftRange(start, end, const Duration(days: 7)),
    AnalyticsPeriod.month => () {
      final previousEnd = DateTime.utc(start.year, start.month, 0);
      final previousStart = DateTime.utc(previousEnd.year, previousEnd.month);

      return (
        startDate: _toLocalDate(previousStart),
        endDate: _toLocalDate(previousEnd),
      );
    }(),
    AnalyticsPeriod.year => (
      startDate: LocalDate(year: start.year - 1, month: 1, day: 1),
      endDate: LocalDate(year: start.year - 1, month: 12, day: 31),
    ),
    AnalyticsPeriod.custom => () {
      final dayCount = end.difference(start).inDays + 1;
      final previousEnd = start.subtract(const Duration(days: 1));
      final previousStart = previousEnd.subtract(Duration(days: dayCount - 1));

      return (
        startDate: _toLocalDate(previousStart),
        endDate: _toLocalDate(previousEnd),
      );
    }(),
  };
}

AnalyticsDateRange _shiftRange(DateTime start, DateTime end, Duration offset) {
  return (
    startDate: _toLocalDate(start.subtract(offset)),
    endDate: _toLocalDate(end.subtract(offset)),
  );
}

DateTime _toDateTime(LocalDate date) {
  return DateTime.utc(date.year, date.month, date.day);
}

LocalDate _toLocalDate(DateTime date) {
  return LocalDate(year: date.year, month: date.month, day: date.day);
}
