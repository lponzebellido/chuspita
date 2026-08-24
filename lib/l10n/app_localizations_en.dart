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
  String get manageWallets => 'Manage wallets';

  @override
  String get manageCategories => 'Manage categories';

  @override
  String get categoriesTitle => 'Categories';

  @override
  String get addCategory => 'Add category';

  @override
  String get newCategoryTitle => 'New category';

  @override
  String get editCategoryTitle => 'Edit category';

  @override
  String get categoryNameLabel => 'Name';

  @override
  String get categoryNameHint => 'For example: Food';

  @override
  String get categoryNameRequired => 'Enter a category name.';

  @override
  String get categoryColorLabel => 'Color';

  @override
  String get noCategoriesTitle => 'You don\'t have any categories yet';

  @override
  String get saveCategoryError =>
      'We couldn\'t save the category. Please try again.';

  @override
  String get addTransaction => 'Add transaction';

  @override
  String get newTransactionTitle => 'New transaction';

  @override
  String get expense => 'Expense';

  @override
  String get income => 'Income';

  @override
  String get amountLabel => 'Amount';

  @override
  String get walletLabel => 'Wallet';

  @override
  String get categoryLabel => 'Category';

  @override
  String get dateLabel => 'Date';

  @override
  String get noteLabel => 'Optional note';

  @override
  String get noteHint => 'For example: Lunch';

  @override
  String get transactionAmountInvalid => 'Enter an amount greater than zero.';

  @override
  String get transactionNeedsWallet =>
      'You need at least one active wallet to record a transaction.';

  @override
  String get transactionNeedsCategory =>
      'You need at least one active category to record a transaction.';

  @override
  String get saveTransactionError =>
      'We couldn\'t save the transaction. Please try again.';

  @override
  String get walletsTitle => 'Wallets';

  @override
  String get editWalletTitle => 'Edit wallet';

  @override
  String get edit => 'Edit';

  @override
  String get archive => 'Archive';

  @override
  String get restore => 'Restore';

  @override
  String get archived => 'Archived';

  @override
  String get walletCurrencyChangeNotAllowed =>
      'The currency can\'t change because this wallet already has financial movements.';

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
  String get save => 'Save';

  @override
  String get walletNameRequired => 'Enter a wallet name.';

  @override
  String get initialBalanceInvalid => 'Enter a valid amount for this currency.';

  @override
  String get saveWalletError =>
      'We couldn\'t save the wallet. Please try again.';
}
