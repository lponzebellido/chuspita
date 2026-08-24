import 'package:chuspita/core/date/local_time.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('validates and represents a local time with minute precision', () {
    final time = LocalTime(hour: 7, minute: 5);

    expect(time.minutesSinceMidnight, 425);
    expect(time.toString(), '07:05');
    expect(LocalTime.fromMinutesSinceMidnight(425), time);
    expect(time.compareTo(LocalTime(hour: 8, minute: 0)), lessThan(0));
  });

  test('rejects values outside a local day', () {
    expect(() => LocalTime(hour: 24, minute: 0), throwsArgumentError);
    expect(() => LocalTime(hour: 12, minute: 60), throwsArgumentError);
    expect(() => LocalTime.fromMinutesSinceMidnight(1440), throwsArgumentError);
  });
}
