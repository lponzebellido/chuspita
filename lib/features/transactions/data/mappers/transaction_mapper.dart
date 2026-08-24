import 'package:chuspita/core/currency/currency.dart';
import 'package:chuspita/core/database/app_database.dart';
import 'package:chuspita/core/date/local_date.dart';
import 'package:chuspita/core/money/money.dart';
import 'package:chuspita/features/categories/domain/category_id.dart';
import 'package:chuspita/features/transactions/domain/transaction.dart';
import 'package:chuspita/features/transactions/domain/transaction_id.dart';
import 'package:chuspita/features/wallets/domain/wallet_id.dart';

extension TransactionRowMapper on TransactionRow {
  Transaction toDomain({required Currency currency}) {
    return Transaction(
      id: TransactionId(id),
      type: _typeFromStorage(type),
      amount: Money(minorUnits: amountMinor, currency: currency),
      walletId: WalletId(walletId),
      categoryId: CategoryId(categoryId),
      occurredOn: LocalDate.parse(occurredOn),
      note: note,
    );
  }
}

TransactionType _typeFromStorage(String value) {
  return switch (value) {
    'income' => TransactionType.income,
    'expense' => TransactionType.expense,
    _ => throw StateError('Unknown transaction type: $value'),
  };
}
