import 'package:chuspita/core/currency/currency.dart';
import 'package:chuspita/core/database/app_database.dart';
import 'package:chuspita/core/date/local_date.dart';
import 'package:chuspita/core/money/money.dart';
import 'package:chuspita/features/transfers/domain/transfer.dart';
import 'package:chuspita/features/transfers/domain/transfer_id.dart';
import 'package:chuspita/features/wallets/domain/wallet_id.dart';

extension TransferRowMapper on TransferRow {
  Transfer toDomain({
    required Currency sourceCurrency,
    required Currency destinationCurrency,
  }) {
    return Transfer(
      id: TransferId(id),
      sourceWalletId: WalletId(sourceWalletId),
      destinationWalletId: WalletId(destinationWalletId),
      sourceAmount: Money(
        minorUnits: sourceAmountMinor,
        currency: sourceCurrency,
      ),
      destinationAmount: Money(
        minorUnits: destinationAmountMinor,
        currency: destinationCurrency,
      ),
      occurredOn: LocalDate.parse(occurredOn),
      note: note,
    );
  }
}
