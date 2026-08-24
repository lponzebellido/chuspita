import 'package:chuspita/core/currency/currency.dart';

final class Money {
  const Money({required this.minorUnits, required this.currency});

  final int minorUnits;
  final Currency currency;

  Money operator +(Money other) {
    _ensureSameCurrency(other);

    return Money(minorUnits: minorUnits + other.minorUnits, currency: currency);
  }

  Money operator -(Money other) {
    _ensureSameCurrency(other);

    return Money(minorUnits: minorUnits - other.minorUnits, currency: currency);
  }

  void _ensureSameCurrency(Money other) {
    if (currency != other.currency) {
      throw ArgumentError(
        'Currencies must match: '
        '${currency.code} != ${other.currency.code}.',
      );
    }
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Money &&
            minorUnits == other.minorUnits &&
            currency == other.currency;
  }

  @override
  int get hashCode => Object.hash(minorUnits, currency);
}
