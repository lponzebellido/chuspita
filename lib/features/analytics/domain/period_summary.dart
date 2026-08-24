import 'package:chuspita/core/currency/currency.dart';
import 'package:chuspita/core/date/local_date.dart';
import 'package:chuspita/core/money/money.dart';

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
  CurrencyPeriodSummary({required this.income, required this.expenses}) {
    if (income.currency != expenses.currency) {
      throw ArgumentError('Income and expenses must use the same currency');
    }

    if (income.minorUnits < 0 || expenses.minorUnits < 0) {
      throw ArgumentError('Income and expenses cannot be negative');
    }
  }

  final Money income;
  final Money expenses;

  Currency get currency => income.currency;

  Money get net => income - expenses;
}
