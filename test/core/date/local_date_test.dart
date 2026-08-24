import 'package:chuspita/core/date/local_date.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalDate', () {
    test('accepts a valid leap day', () {
      final date = LocalDate(year: 2024, month: 2, day: 29);

      expect(date.year, 2024);
      expect(date.month, 2);
      expect(date.day, 29);
    });

    test('rejects invalid calendar dates', () {
      expect(
        () => LocalDate(year: 2025, month: 2, day: 29),
        throwsArgumentError,
      );
      expect(
        () => LocalDate(year: 2025, month: 13, day: 1),
        throwsArgumentError,
      );
    });

    test('compares dates chronologically', () {
      final january = LocalDate(year: 2026, month: 1, day: 31);
      final february = LocalDate(year: 2026, month: 2, day: 1);

      expect(january.compareTo(february), lessThan(0));
      expect(february.compareTo(january), greaterThan(0));
    });

    test('uses value equality and ISO representation', () {
      final first = LocalDate(year: 2026, month: 8, day: 23);
      final second = LocalDate(year: 2026, month: 8, day: 23);

      expect(first, second);
      expect(first.hashCode, second.hashCode);
      expect(first.toString(), '2026-08-23');
    });
  });
}
