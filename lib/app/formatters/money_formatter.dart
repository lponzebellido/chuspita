import 'package:chuspita/core/money/money.dart';
import 'package:intl/intl.dart';

String formatMoneyAmount(Money money, {required String localeName}) {
  var divisor = 1;

  for (var digit = 0; digit < money.currency.minorUnitDigits; digit++) {
    divisor *= 10;
  }

  final absoluteUnits = money.minorUnits.abs();
  final wholeUnits = absoluteUnits ~/ divisor;
  final sign = money.minorUnits < 0 ? '-' : '';

  if (money.currency.minorUnitDigits == 0) {
    return '$sign$wholeUnits';
  }

  final decimalSeparator = NumberFormat.decimalPattern(localeName)
      .symbols
      .DECIMAL_SEP;
  final decimalUnits = (absoluteUnits % divisor).toString().padLeft(
    money.currency.minorUnitDigits,
    '0',
  );

  return '$sign$wholeUnits$decimalSeparator$decimalUnits';
}
