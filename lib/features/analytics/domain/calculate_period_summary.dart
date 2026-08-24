import 'package:chuspita/core/currency/currency.dart';
import 'package:chuspita/core/date/local_date.dart';
import 'package:chuspita/core/money/money.dart';
import 'package:chuspita/features/analytics/domain/period_summary.dart';
import 'package:chuspita/features/categories/domain/category_id.dart';
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
  final expenseCounts = <Currency, int>{};
  final largestExpenseTotals = <Currency, int>{};
  final expenseTotalsByCategory = <Currency, Map<CategoryId, int>>{};

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

    if (transaction.type == TransactionType.expense) {
      expenseCounts.update(
        transaction.amount.currency,
        (current) => current + 1,
        ifAbsent: () => 1,
      );
      largestExpenseTotals.update(
        transaction.amount.currency,
        (current) => current > transaction.amount.minorUnits
            ? current
            : transaction.amount.minorUnits,
        ifAbsent: () => transaction.amount.minorUnits,
      );
      final totalsByCategory = expenseTotalsByCategory.putIfAbsent(
        transaction.amount.currency,
        () => <CategoryId, int>{},
      );

      totalsByCategory.update(
        transaction.categoryId,
        (current) => current + transaction.amount.minorUnits,
        ifAbsent: () => transaction.amount.minorUnits,
      );
    }
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
      expenseCount: expenseCounts[currency] ?? 0,
      largestExpense: Money(
        minorUnits: largestExpenseTotals[currency] ?? 0,
        currency: currency,
      ),
      expensesByCategory: {
        for (final entry
            in (expenseTotalsByCategory[currency] ?? const <CategoryId, int>{})
                .entries)
          entry.key: Money(minorUnits: entry.value, currency: currency),
      },
    );
  }

  return PeriodSummary(
    startDate: startDate,
    endDate: endDate,
    byCurrency: byCurrency,
  );
}
