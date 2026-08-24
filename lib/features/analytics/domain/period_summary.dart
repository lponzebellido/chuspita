import 'package:chuspita/core/currency/currency.dart';
import 'package:chuspita/core/date/local_date.dart';
import 'package:chuspita/core/money/money.dart';
import 'package:chuspita/features/categories/domain/category_id.dart';

final class PeriodSummary {
  PeriodSummary({
    required this.startDate,
    required this.endDate,
    required Map<Currency, CurrencyPeriodSummary> byCurrency,
  }) : byCurrency = Map.unmodifiable(byCurrency) {
    if (startDate.compareTo(endDate) > 0) {
      throw ArgumentError('The start date cannot be after the end date');
    }

    for (final entry in byCurrency.entries) {
      if (entry.key != entry.value.currency) {
        throw ArgumentError('The summary currency must match its map key');
      }
    }
  }

  final LocalDate startDate;
  final LocalDate endDate;
  final Map<Currency, CurrencyPeriodSummary> byCurrency;

  bool get isEmpty => byCurrency.isEmpty;
}

final class CurrencyPeriodSummary {
  CurrencyPeriodSummary({
    required this.income,
    required this.expenses,
    required this.expenseCount,
    required this.largestExpense,
    required Map<CategoryId, Money> expensesByCategory,
  }) : expensesByCategory = Map.unmodifiable(expensesByCategory) {
    if (income.currency != expenses.currency) {
      throw ArgumentError('Income and expenses must use the same currency');
    }

    if (largestExpense.currency != expenses.currency) {
      throw ArgumentError('The largest expense must use the summary currency');
    }

    if (expenseCount < 0) {
      throw ArgumentError('The expense count cannot be negative');
    }

    if ((expenses.minorUnits == 0) != (expenseCount == 0)) {
      throw ArgumentError('Expense total and count must both be empty or set');
    }

    if (largestExpense.minorUnits < 0 ||
        largestExpense.minorUnits > expenses.minorUnits ||
        (expenseCount > 0 && largestExpense.minorUnits == 0)) {
      throw ArgumentError('The largest expense is inconsistent with totals');
    }

    if (income.minorUnits < 0 || expenses.minorUnits < 0) {
      throw ArgumentError('Income and expenses cannot be negative');
    }

    var categorizedExpenses = 0;

    for (final amount in expensesByCategory.values) {
      if (amount.currency != expenses.currency) {
        throw ArgumentError('Category expenses must use the summary currency');
      }

      if (amount.minorUnits <= 0) {
        throw ArgumentError('Category expenses must be greater than zero');
      }

      categorizedExpenses += amount.minorUnits;
    }

    if (categorizedExpenses != expenses.minorUnits) {
      throw ArgumentError('Category expenses must add up to the expense total');
    }
  }

  final Money income;
  final Money expenses;
  final int expenseCount;
  final Money largestExpense;
  final Map<CategoryId, Money> expensesByCategory;

  Currency get currency => income.currency;

  Money get net => income - expenses;

  Money get averageExpense {
    if (expenseCount == 0) {
      return Money(minorUnits: 0, currency: currency);
    }

    return Money(
      minorUnits: (expenses.minorUnits + expenseCount ~/ 2) ~/ expenseCount,
      currency: currency,
    );
  }

  MapEntry<CategoryId, Money>? get topExpenseCategory {
    MapEntry<CategoryId, Money>? topCategory;

    for (final entry in expensesByCategory.entries) {
      final current = topCategory;

      if (current == null ||
          entry.value.minorUnits > current.value.minorUnits ||
          entry.value.minorUnits == current.value.minorUnits &&
              entry.key.value.compareTo(current.key.value) < 0) {
        topCategory = entry;
      }
    }

    return topCategory;
  }

  bool get hasExpenses => expenses.minorUnits > 0;
}
