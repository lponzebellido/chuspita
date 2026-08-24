import 'package:chuspita/core/currency/currency.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Currency', () {
    test('exposes canonical ISO metadata', () {
      expect(Currency.eur.code, 'EUR');
      expect(Currency.eur.minorUnitDigits, 2);
      expect(Currency.jpy.minorUnitDigits, 0);
      expect(Currency.kwd.minorUnitDigits, 3);
    });

    test('normalizes codes during lookup', () {
      expect(Currency.fromCode(' eur '), Currency.eur);
    });

    test('rejects unsupported currency codes', () {
      expect(() => Currency.fromCode('ZZZ'), throwsArgumentError);
    });
  });
}
