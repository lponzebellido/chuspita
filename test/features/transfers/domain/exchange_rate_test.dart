import 'package:chuspita/core/currency/currency.dart';
import 'package:chuspita/core/money/money.dart';
import 'package:chuspita/features/transfers/domain/exchange_rate.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExchangeRate', () {
    test('parses comma or dot and converts without floating-point errors', () {
      final rate = ExchangeRate.parse(
        value: '4,1235',
        sourceCurrency: Currency.eur,
        destinationCurrency: Currency.pen,
      );

      final converted = rate.convert(
        const Money(minorUnits: 1000, currency: Currency.eur),
      );

      expect(converted, const Money(minorUnits: 4124, currency: Currency.pen));
      expect(rate.toInputValue(), '4.1235');
    });

    test('respects currencies with different minor unit digits', () {
      final rate = ExchangeRate.parse(
        value: '163.25',
        sourceCurrency: Currency.usd,
        destinationCurrency: Currency.jpy,
      );

      final converted = rate.convert(
        const Money(minorUnits: 1050, currency: Currency.usd),
      );

      expect(converted, const Money(minorUnits: 1714, currency: Currency.jpy));
    });

    test('derives a reusable rate from transfer amounts', () {
      final rate = ExchangeRate.fromAmounts(
        sourceAmount: const Money(minorUnits: 1000, currency: Currency.eur),
        destinationAmount: const Money(
          minorUnits: 4123,
          currency: Currency.pen,
        ),
      );

      expect(rate.toInputValue(), '4.123');
    });

    test('rejects zero, negative and overly precise rates', () {
      ExchangeRate parse(String value) => ExchangeRate.parse(
        value: value,
        sourceCurrency: Currency.eur,
        destinationCurrency: Currency.pen,
      );

      expect(() => parse('0'), throwsFormatException);
      expect(() => parse('-1'), throwsFormatException);
      expect(() => parse('1.12345678901'), throwsFormatException);
    });
  });
}
