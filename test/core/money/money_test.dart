import 'package:chuspita/core/currency/currency.dart';
import 'package:chuspita/core/money/money.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Money', () {
    test('can represent negative amounts', () {
      const money = Money(minorUnits: -500, currency: Currency.eur);

      expect(money.minorUnits, -500);
    });

    test('adds amounts with the same currency', () {
      const left = Money(minorUnits: 1250, currency: Currency.eur);
      const right = Money(minorUnits: 375, currency: Currency.eur);

      expect(
        left + right,
        const Money(minorUnits: 1625, currency: Currency.eur),
      );
    });

    test('subtracts amounts with the same currency', () {
      const left = Money(minorUnits: 1250, currency: Currency.eur);
      const right = Money(minorUnits: 375, currency: Currency.eur);

      expect(
        left - right,
        const Money(minorUnits: 875, currency: Currency.eur),
      );
    });

    test('rejects operations between different currencies', () {
      const euros = Money(minorUnits: 100, currency: Currency.eur);
      const dollars = Money(minorUnits: 100, currency: Currency.usd);

      expect(() => euros + dollars, throwsArgumentError);
      expect(() => euros - dollars, throwsArgumentError);
    });

    test('uses value equality', () {
      const first = Money(minorUnits: 1253, currency: Currency.eur);
      const second = Money(minorUnits: 1253, currency: Currency.eur);

      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });
  });
}
