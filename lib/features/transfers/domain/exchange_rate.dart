import 'package:chuspita/core/currency/currency.dart';
import 'package:chuspita/core/money/money.dart';

final class ExchangeRate {
  factory ExchangeRate.parse({
    required String value,
    required Currency sourceCurrency,
    required Currency destinationCurrency,
  }) {
    final normalized = value.trim().replaceAll(' ', '').replaceAll(',', '.');
    final match = RegExp(r'^(\d+)(?:\.(\d+))?$').firstMatch(normalized);

    if (match == null) {
      throw FormatException('Invalid exchange rate', value);
    }

    final fraction = match.group(2) ?? '';

    if (fraction.length > maximumDecimalPlaces) {
      throw FormatException(
        'Exchange rate supports at most $maximumDecimalPlaces decimal places',
        value,
      );
    }

    final units = BigInt.parse('${match.group(1)}$fraction');

    if (units <= BigInt.zero) {
      throw FormatException('Exchange rate must be greater than zero', value);
    }

    return ExchangeRate._(
      sourceCurrency,
      destinationCurrency,
      units,
      fraction.length,
    );
  }

  factory ExchangeRate.fromAmounts({
    required Money sourceAmount,
    required Money destinationAmount,
  }) {
    if (sourceAmount.minorUnits <= 0 || destinationAmount.minorUnits <= 0) {
      throw ArgumentError('Exchange rate amounts must be greater than zero');
    }

    final numerator =
        BigInt.from(destinationAmount.minorUnits) *
        _powerOfTen(sourceAmount.currency.minorUnitDigits + storedPrecision);
    final denominator =
        BigInt.from(sourceAmount.minorUnits) *
        _powerOfTen(destinationAmount.currency.minorUnitDigits);
    final units = _divideAndRound(numerator, denominator);

    if (units <= BigInt.zero) {
      throw ArgumentError('Exchange rate is too small to represent');
    }

    return ExchangeRate._(
      sourceAmount.currency,
      destinationAmount.currency,
      units,
      storedPrecision,
    );
  }

  const ExchangeRate._(
    this.sourceCurrency,
    this.destinationCurrency,
    this._units,
    this.decimalPlaces,
  );

  static const maximumDecimalPlaces = 10;
  static const storedPrecision = 8;

  final Currency sourceCurrency;
  final Currency destinationCurrency;
  final BigInt _units;
  final int decimalPlaces;

  Money convert(Money sourceAmount) {
    if (sourceAmount.currency != sourceCurrency) {
      throw ArgumentError(
        'Expected ${sourceCurrency.code}, got ${sourceAmount.currency.code}',
      );
    }

    if (sourceAmount.minorUnits <= 0) {
      throw ArgumentError('Source amount must be greater than zero');
    }

    final numerator =
        BigInt.from(sourceAmount.minorUnits) *
        _units *
        _powerOfTen(destinationCurrency.minorUnitDigits);
    final denominator = _powerOfTen(
      sourceCurrency.minorUnitDigits + decimalPlaces,
    );
    final destinationMinorUnits = _divideAndRound(numerator, denominator);

    return Money(
      minorUnits: destinationMinorUnits.toInt(),
      currency: destinationCurrency,
    );
  }

  String toInputValue() {
    if (decimalPlaces == 0) {
      return _units.toString();
    }

    final digits = _units.toString().padLeft(decimalPlaces + 1, '0');
    final whole = digits.substring(0, digits.length - decimalPlaces);
    final fraction = digits
        .substring(digits.length - decimalPlaces)
        .replaceFirst(RegExp(r'0+$'), '');

    return fraction.isEmpty ? whole : '$whole.$fraction';
  }
}

BigInt _powerOfTen(int exponent) {
  return BigInt.from(10).pow(exponent);
}

BigInt _divideAndRound(BigInt numerator, BigInt denominator) {
  final quotient = numerator ~/ denominator;
  final remainder = numerator.remainder(denominator);

  return remainder * BigInt.two >= denominator
      ? quotient + BigInt.one
      : quotient;
}
