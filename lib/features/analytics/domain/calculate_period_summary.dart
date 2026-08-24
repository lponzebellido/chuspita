import 'package:chuspita/core/currency/currency.dart';
import 'package:chuspita/core/date/local_date.dart';
import 'package:chuspita/core/money/money.dart';
import 'package:chuspita/features/analytics/domain/period_summary.dart';
import 'package:chuspita/features/transactions/domain/transaction.dart';

PeriodSummary calculatePeriodSummary({
  required Iterable<Transaction> transactions,
  required LocalDate startDate,
  required LocalDate endDate,
}) {
  if (startDate.compareTo(endDate) > 0) {
    throw ArgumentError('The start date cannot be after the end date');
  }

  final incomeTotals = <Currency, int>{};
  final expenseTotals = <Currency, int>{};

  for (final transaction in transactions) {
    if (transaction.occurredOn.compareTo(startDate) < 0 ||
        transaction.occurredOn.compareTo(endDate) > 0) {
      continue;
    }

    final totals = transaction.type == TransactionType.income
        ? incomeTotals
        : expenseTotals;

    totals.update(
      transaction.amount.currency,
      (current) => current + transaction.amount.minorUnits,
      ifAbsent: () => transaction.amount.minorUnits,
    );
  }

  final currencies = <Currency>{...incomeTotals.keys, ...expenseTotals.keys};
  final byCurrency = <Currency, CurrencyPeriodSummary>{};

  for (final currency in currencies) {
    byCurrency[currency] = CurrencyPeriodSummary(
      income: Money(
        minorUnits: incomeTotals[currency] ?? 0,
        currency: currency,
      ),
      expenses: Money(
        minorUnits: expenseTotals[currency] ?? 0,
        currency: currency,
      ),
    );
  }

  return PeriodSummary(
    startDate: startDate,
    endDate: endDate,
    byCurrency: byCurrency,
  );
}
