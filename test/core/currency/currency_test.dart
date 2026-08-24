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

    test('exposes the supported currency catalog', () {
      expect(Currency.supported, containsAll([Currency.eur, Currency.pen]));
      expect(() => Currency.supported.clear(), throwsUnsupportedError);
    });

    test('rejects unsupported currency codes', () {
      expect(() => Currency.fromCode('ZZZ'), throwsArgumentError);
    });
  });
}
