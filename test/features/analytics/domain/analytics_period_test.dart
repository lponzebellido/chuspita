import 'package:chuspita/core/date/local_date.dart';
import 'package:chuspita/features/analytics/domain/analytics_period.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('finds the previous day', () {
    expect(
      previousEquivalentPeriod(
        period: AnalyticsPeriod.day,
        startDate: LocalDate(year: 2026, month: 8, day: 24),
        endDate: LocalDate(year: 2026, month: 8, day: 24),
      ),
      (
        startDate: LocalDate(year: 2026, month: 8, day: 23),
        endDate: LocalDate(year: 2026, month: 8, day: 23),
      ),
    );
  });

  test('finds the previous week', () {
    expect(
      previousEquivalentPeriod(
        period: AnalyticsPeriod.week,
        startDate: LocalDate(year: 2026, month: 8, day: 24),
        endDate: LocalDate(year: 2026, month: 8, day: 30),
      ),
      (
        startDate: LocalDate(year: 2026, month: 8, day: 17),
        endDate: LocalDate(year: 2026, month: 8, day: 23),
      ),
    );
  });

  test('finds the previous calendar month', () {
    expect(
      previousEquivalentPeriod(
        period: AnalyticsPeriod.month,
        startDate: LocalDate(year: 2024, month: 3, day: 1),
        endDate: LocalDate(year: 2024, month: 3, day: 31),
      ),
      (
        startDate: LocalDate(year: 2024, month: 2, day: 1),
        endDate: LocalDate(year: 2024, month: 2, day: 29),
      ),
    );
  });

  test('finds the previous calendar year', () {
    expect(
      previousEquivalentPeriod(
        period: AnalyticsPeriod.year,
        startDate: LocalDate(year: 2026, month: 1, day: 1),
        endDate: LocalDate(year: 2026, month: 12, day: 31),
      ),
      (
        startDate: LocalDate(year: 2025, month: 1, day: 1),
        endDate: LocalDate(year: 2025, month: 12, day: 31),
      ),
    );
  });

  test('uses the same inclusive duration for a custom period', () {
    expect(
      previousEquivalentPeriod(
        period: AnalyticsPeriod.custom,
        startDate: LocalDate(year: 2026, month: 8, day: 10),
        endDate: LocalDate(year: 2026, month: 8, day: 14),
      ),
      (
        startDate: LocalDate(year: 2026, month: 8, day: 5),
        endDate: LocalDate(year: 2026, month: 8, day: 9),
      ),
    );
  });
}
