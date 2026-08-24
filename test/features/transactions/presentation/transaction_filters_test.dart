import 'package:chuspita/core/currency/currency.dart';
import 'package:chuspita/core/date/local_date.dart';
import 'package:chuspita/core/money/money.dart';
import 'package:chuspita/features/categories/domain/category_id.dart';
import 'package:chuspita/features/transactions/domain/transaction.dart';
import 'package:chuspita/features/transactions/domain/transaction_id.dart';
import 'package:chuspita/features/transactions/presentation/transaction_filters.dart';
import 'package:chuspita/features/wallets/domain/wallet_id.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('combines type, wallet, category and inclusive date filters', () {
    final matching = buildTransaction(
      id: 'matching',
      occurredOn: LocalDate(year: 2026, month: 8, day: 15),
    );
    final wrongType = buildTransaction(
      id: 'income',
      type: TransactionType.income,
      occurredOn: LocalDate(year: 2026, month: 8, day: 15),
    );
    final outsidePeriod = buildTransaction(
      id: 'outside',
      occurredOn: LocalDate(year: 2026, month: 9, day: 1),
    );
    final filters = TransactionFilters(
      type: TransactionType.expense,
      walletId: WalletId('wallet-1'),
      categoryId: CategoryId('category-1'),
      startDate: LocalDate(year: 2026, month: 8, day: 1),
      endDate: LocalDate(year: 2026, month: 8, day: 31),
    );

    final result = filters.apply([matching, wrongType, outsidePeriod]);

    expect(result, [matching]);
    expect(filters.activeCount, 4);
  });

  test('requires a complete and ordered date range', () {
    expect(
      () => TransactionFilters(
        startDate: LocalDate(year: 2026, month: 8, day: 1),
      ),
      throwsArgumentError,
    );
    expect(
      () => TransactionFilters(
        startDate: LocalDate(year: 2026, month: 9, day: 1),
        endDate: LocalDate(year: 2026, month: 8, day: 1),
      ),
      throwsArgumentError,
    );
  });
}

Transaction buildTransaction({
  required String id,
  required LocalDate occurredOn,
  TransactionType type = TransactionType.expense,
}) {
  return Transaction(
    id: TransactionId(id),
    type: type,
    amount: const Money(minorUnits: 1000, currency: Currency.eur),
    walletId: WalletId('wallet-1'),
    categoryId: CategoryId('category-1'),
    occurredOn: occurredOn,
  );
}
