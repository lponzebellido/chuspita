// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Chuspita';

  @override
  String get balanceByCurrency => 'Balance by currency';

  @override
  String get noWalletsTitle => 'You don\'t have any wallets yet';

  @override
  String get noWalletsBody =>
      'Your balance will appear here after you create the first one.';

  @override
  String get addWallet => 'Add wallet';

  @override
  String get loadDataError => 'We couldn\'t load your data.';

  @override
  String get retry => 'Retry';

  @override
  String get newWalletTitle => 'New wallet';

  @override
  String get walletNameLabel => 'Name';

  @override
  String get walletNameHint => 'For example: Cash';

  @override
  String get currencyLabel => 'Currency';

  @override
  String get initialBalanceLabel => 'Initial balance';

  @override
  String get walletColorLabel => 'Color';

  @override
  String get save => 'Save';

  @override
  String get walletNameRequired => 'Enter a wallet name.';

  @override
  String get initialBalanceInvalid => 'Enter a valid amount for this currency.';

  @override
  String get saveWalletError =>
      'We couldn\'t save the wallet. Please try again.';
}
