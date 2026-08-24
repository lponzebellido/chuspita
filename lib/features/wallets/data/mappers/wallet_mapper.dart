import 'package:chuspita/core/color/argb_color.dart';
import 'package:chuspita/core/currency/currency.dart';
import 'package:chuspita/core/database/app_database.dart';
import 'package:chuspita/core/money/money.dart';
import 'package:chuspita/features/wallets/domain/wallet.dart';
import 'package:chuspita/features/wallets/domain/wallet_id.dart';

extension WalletRowMapper on WalletRow {
  Wallet toDomain() {
    final currency = Currency.fromCode(currencyCode);

    return Wallet(
      id: WalletId(id),
      name: name,
      initialBalance: Money(
        minorUnits: initialBalanceMinor,
        currency: currency,
      ),
      color: ArgbColor(colorArgb),
      isArchived: isArchived,
    );
  }
}
