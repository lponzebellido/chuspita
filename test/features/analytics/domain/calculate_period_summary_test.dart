import 'package:chuspita/core/currency/currency.dart';
import 'package:chuspita/core/date/local_date.dart';
import 'package:chuspita/core/money/money.dart';
import 'package:chuspita/features/analytics/domain/calculate_period_summary.dart';
import 'package:chuspita/features/categories/domain/category_id.dart';
import 'package:chuspita/features/transactions/domain/transaction.dart';
import 'package:chuspita/features/transactions/domain/transaction_id.dart';
import 'package:chuspita/features/wallets/domain/wallet_id.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('summarizes income and expenses by currency inside the period', () {
    final summary = calculatePeriodSummary(
      transactions: [
        buildTransaction(
          id: 'eur-income',
          type: TransactionType.income,
          amount: const Money(minorUnits: 10000, currency: Currency.eur),
          occurredOn: LocalDate(year: 2026, month: 8, day: 1),
        ),
        buildTransaction(
          id: 'eur-expense',
          type: TransactionType.expense,
          amount: const Money(minorUnits: 2500, currency: Currency.eur),
          occurredOn: LocalDate(year: 2026, month: 8, day: 31),
          categoryId: 'food',
        ),
        buildTransaction(
          id: 'second-eur-expense',
          type: TransactionType.expense,
          amount: const Money(minorUnits: 500, currency: Currency.eur),
          occurredOn: LocalDate(year: 2026, month: 8, day: 20),
          categoryId: 'transport',
        ),
        buildTransaction(
          id: 'pen-expense',
          type: TransactionType.expense,
          amount: const Money(minorUnits: 4000, currency: Currency.pen),
          occurredOn: LocalDate(year: 2026, month: 8, day: 15),
          categoryId: 'food',
        ),
        buildTransaction(
          id: 'outside-period',
          type: TransactionType.income,
          amount: const Money(minorUnits: 99999, currency: Currency.eur),
          occurredOn: LocalDate(year: 2026, month: 9, day: 1),
        ),
      ],
      startDate: LocalDate(year: 2026, month: 8, day: 1),
      endDate: LocalDate(year: 2026, month: 8, day: 31),
    );

    expect(
      summary.byCurrency[Currency.eur]!.income,
      const Money(minorUnits: 10000, currency: Currency.eur),
    );
    expect(
      summary.byCurrency[Currency.eur]!.expenses,
      const Money(minorUnits: 3000, currency: Currency.eur),
    );
    expect(
      summary.byCurrency[Currency.eur]!.net,
      const Money(minorUnits: 7000, currency: Currency.eur),
    );
    expect(summary.byCurrency[Currency.eur]!.expenseCount, 2);
    expect(
      summary.byCurrency[Currency.eur]!.averageExpense,
      const Money(minorUnits: 1500, currency: Currency.eur),
    );
    expect(
      summary.byCurrency[Currency.eur]!.largestExpense,
      const Money(minorUnits: 2500, currency: Currency.eur),
    );
    expect(
      summary.byCurrency[Currency.eur]!.topExpenseCategory!.key,
      CategoryId('food'),
    );
    expect(summary.byCurrency[Currency.eur]!.expensesByCategory, {
      CategoryId('food'): const Money(minorUnits: 2500, currency: Currency.eur),
      CategoryId('transport'): const Money(
        minorUnits: 500,
        currency: Currency.eur,
      ),
    });
    expect(
      summary.byCurrency[Currency.pen]!.income,
      const Money(minorUnits: 0, currency: Currency.pen),
    );
    expect(
      summary.byCurrency[Currency.pen]!.expenses,
      const Money(minorUnits: 4000, currency: Currency.pen),
    );
    expect(
      summary.byCurrency[Currency.pen]!.net,
      const Money(minorUnits: -4000, currency: Currency.pen),
    );
    expect(summary.byCurrency[Currency.pen]!.expenseCount, 1);
    expect(
      summary.byCurrency[Currency.pen]!.averageExpense,
      const Money(minorUnits: 4000, currency: Currency.pen),
    );
    expect(
      summary.byCurrency[Currency.pen]!.largestExpense,
      const Money(minorUnits: 4000, currency: Currency.pen),
    );
    expect(summary.byCurrency[Currency.pen]!.expensesByCategory, {
      CategoryId('food'): const Money(minorUnits: 4000, currency: Currency.pen),
    });
  });

  test('returns an empty summary when the period has no transactions', () {
    final summary = calculatePeriodSummary(
      transactions: const [],
      startDate: LocalDate(year: 2026, month: 8, day: 1),
      endDate: LocalDate(year: 2026, month: 8, day: 31),
    );

    expect(summary.isEmpty, isTrue);
  });

  test('rounds average expenses to the nearest minor unit', () {
    final summary = calculatePeriodSummary(
      transactions: [
        buildTransaction(
          id: 'first',
          type: TransactionType.expense,
          amount: const Money(minorUnits: 100, currency: Currency.eur),
          occurredOn: LocalDate(year: 2026, month: 8, day: 1),
        ),
        buildTransaction(
          id: 'second',
          type: TransactionType.expense,
          amount: const Money(minorUnits: 101, currency: Currency.eur),
          occurredOn: LocalDate(year: 2026, month: 8, day: 2),
        ),
      ],
      startDate: LocalDate(year: 2026, month: 8, day: 1),
      endDate: LocalDate(year: 2026, month: 8, day: 31),
    );

    expect(
      summary.byCurrency[Currency.eur]!.averageExpense,
      const Money(minorUnits: 101, currency: Currency.eur),
    );
  });

  test('uses empty spending metrics for an income-only period', () {
    final summary = calculatePeriodSummary(
      transactions: [
        buildTransaction(
          id: 'income',
          type: TransactionType.income,
          amount: const Money(minorUnits: 5000, currency: Currency.eur),
          occurredOn: LocalDate(year: 2026, month: 8, day: 1),
        ),
      ],
      startDate: LocalDate(year: 2026, month: 8, day: 1),
      endDate: LocalDate(year: 2026, month: 8, day: 31),
    );
    final currencySummary = summary.byCurrency[Currency.eur]!;

    expect(currencySummary.expenseCount, 0);
    expect(
      currencySummary.averageExpense,
      const Money(minorUnits: 0, currency: Currency.eur),
    );
    expect(
      currencySummary.largestExpense,
      const Money(minorUnits: 0, currency: Currency.eur),
    );
    expect(currencySummary.topExpenseCategory, isNull);
  });

  test('rejects an inverted period', () {
    expect(
      () => calculatePeriodSummary(
        transactions: const [],
        startDate: LocalDate(year: 2026, month: 9, day: 1),
        endDate: LocalDate(year: 2026, month: 8, day: 31),
      ),
      throwsArgumentError,
    );
  });
}

Transaction buildTransaction({
  required String id,
  required TransactionType type,
  required Money amount,
  required LocalDate occurredOn,
  String categoryId = 'category-1',
}) {
  return Transaction(
    id: TransactionId(id),
    type: type,
    amount: amount,
    walletId: WalletId('wallet-${amount.currency.code}'),
    categoryId: CategoryId(categoryId),
    occurredOn: occurredOn,
  );
}
