import 'package:chuspita/core/currency/currency.dart';
import 'package:chuspita/core/date/local_date.dart';
import 'package:chuspita/core/money/money.dart';
import 'package:chuspita/features/categories/domain/category_id.dart';
import 'package:chuspita/features/movements/presentation/movement_filters.dart';
import 'package:chuspita/features/movements/presentation/movement_item.dart';
import 'package:chuspita/features/transactions/domain/transaction.dart';
import 'package:chuspita/features/transactions/domain/transaction_id.dart';
import 'package:chuspita/features/transfers/domain/transfer.dart';
import 'package:chuspita/features/transfers/domain/transfer_id.dart';
import 'package:chuspita/features/wallets/domain/wallet_id.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('combines type, wallet, category and inclusive date filters', () {
    final matching = TransactionMovementItem(
      buildTransaction(
        id: 'matching',
        occurredOn: LocalDate(year: 2026, month: 8, day: 15),
      ),
    );
    final wrongType = TransactionMovementItem(
      buildTransaction(
        id: 'income',
        type: TransactionType.income,
        occurredOn: LocalDate(year: 2026, month: 8, day: 15),
      ),
    );
    final outsidePeriod = TransactionMovementItem(
      buildTransaction(
        id: 'outside',
        occurredOn: LocalDate(year: 2026, month: 9, day: 1),
      ),
    );
    final filters = MovementFilters(
      type: MovementType.expense,
      walletId: WalletId('wallet-1'),
      categoryId: CategoryId('category-1'),
      startDate: LocalDate(year: 2026, month: 8, day: 1),
      endDate: LocalDate(year: 2026, month: 8, day: 31),
    );

    final result = filters.apply([matching, wrongType, outsidePeriod]);

    expect(result, [matching]);
    expect(filters.activeCount, 4);
  });

  test('matches a transfer through either wallet without a category', () {
    final transfer = TransferMovementItem(buildTransfer());

    expect(
      MovementFilters(walletId: WalletId('source-wallet')).matches(transfer),
      isTrue,
    );
    expect(
      MovementFilters(walletId: WalletId('destination-wallet'))
          .matches(transfer),
      isTrue,
    );
    expect(
      MovementFilters(categoryId: CategoryId('category-1')).matches(transfer),
      isFalse,
    );
  });

  test('requires valid filter combinations and date ranges', () {
    expect(
      () => MovementFilters(
        type: MovementType.transfer,
        categoryId: CategoryId('category-1'),
      ),
      throwsArgumentError,
    );
    expect(
      () => MovementFilters(startDate: LocalDate(year: 2026, month: 8, day: 1)),
      throwsArgumentError,
    );
    expect(
      () => MovementFilters(
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

Transfer buildTransfer() {
  return Transfer(
    id: TransferId('transfer-1'),
    sourceWalletId: WalletId('source-wallet'),
    destinationWalletId: WalletId('destination-wallet'),
    sourceAmount: const Money(minorUnits: 1000, currency: Currency.eur),
    destinationAmount: const Money(minorUnits: 4000, currency: Currency.pen),
    occurredOn: LocalDate(year: 2026, month: 8, day: 15),
  );
}
