import 'package:chuspita/core/currency/currency.dart';
import 'package:chuspita/core/money/money.dart';

Money parseMoney(String value, Currency currency) {
  final normalized = value.trim().replaceAll(' ', '').replaceAll(',', '.');
  final match = RegExp(r'^([+-]?)(\d+)(?:\.(\d+))?$').firstMatch(normalized);

  if (match == null) {
    throw FormatException('Invalid monetary amount', value);
  }

  final fraction = match.group(3) ?? '';

  if (fraction.length > currency.minorUnitDigits) {
    throw FormatException(
      'Amount has too many decimal places for ${currency.code}',
      value,
    );
  }

  var factor = 1;

  for (var digit = 0; digit < currency.minorUnitDigits; digit++) {
    factor *= 10;
  }

  final wholeMinorUnits = int.parse(match.group(2)!) * factor;
  final fractionMinorUnits = fraction.isEmpty
      ? 0
      : int.parse(fraction.padRight(currency.minorUnitDigits, '0'));
  final sign = match.group(1) == '-' ? -1 : 1;

  return Money(
    minorUnits: sign * (wholeMinorUnits + fractionMinorUnits),
    currency: currency,
  );
}
