import 'package:chuspita/core/currency/currency.dart';
import 'package:chuspita/core/money/money.dart';
import 'package:chuspita/features/wallets/domain/wallet_id.dart';

final class BalanceSummary {
  BalanceSummary({
    required Map<WalletId, Money> byWallet,
    required Map<Currency, Money> byCurrency,
    Map<WalletId, String> walletNames = const {},
  }) : byWallet = Map.unmodifiable(byWallet),
       byCurrency = Map.unmodifiable(byCurrency),
       walletNames = Map.unmodifiable(walletNames);

  final Map<WalletId, Money> byWallet;
  final Map<Currency, Money> byCurrency;
  final Map<WalletId, String> walletNames;
}
