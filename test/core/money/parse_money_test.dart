import 'package:chuspita/core/currency/currency.dart';
import 'package:chuspita/core/money/money.dart';
import 'package:chuspita/core/money/parse_money.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseMoney', () {
    test('parses dot and comma decimal separators exactly', () {
      expect(
        parseMoney('12.53', Currency.eur),
        const Money(minorUnits: 1253, currency: Currency.eur),
      );
      expect(
        parseMoney('12,53', Currency.eur),
        const Money(minorUnits: 1253, currency: Currency.eur),
      );
    });

    test('respects currency minor unit digits', () {
      expect(
        parseMoney('125', Currency.jpy),
        const Money(minorUnits: 125, currency: Currency.jpy),
      );
      expect(
        parseMoney('1.234', Currency.kwd),
        const Money(minorUnits: 1234, currency: Currency.kwd),
      );
    });

    test('parses negative initial balances', () {
      expect(
        parseMoney('-10,50', Currency.eur),
        const Money(minorUnits: -1050, currency: Currency.eur),
      );
    });

    test('rejects invalid values and excessive decimal places', () {
      expect(() => parseMoney('twelve', Currency.eur), throwsFormatException);
      expect(() => parseMoney('1.234', Currency.eur), throwsFormatException);
      expect(() => parseMoney('1.5', Currency.jpy), throwsFormatException);
    });
  });
}
