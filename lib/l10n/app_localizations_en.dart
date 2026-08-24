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
  String get settingsTitle => 'Settings';

  @override
  String get languageSettingsTitle => 'Language';

  @override
  String get appearanceSettingsTitle => 'Appearance';

  @override
  String get systemOption => 'System';

  @override
  String get spanishLanguage => 'Spanish';

  @override
  String get englishLanguage => 'English';

  @override
  String get lightTheme => 'Light';

  @override
  String get darkTheme => 'Dark';

  @override
  String get saveSettingsError =>
      'We couldn\'t save the settings. Please try again.';

  @override
  String get loadSettingsError => 'We couldn\'t load the settings.';

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
  String get categoryApplicabilityLabel => 'Use for';

  @override
  String get categoryExpenseOption => 'Expenses';

  @override
  String get categoryIncomeOption => 'Income';

  @override
  String get categoryBothOption => 'Both';

  @override
  String get categoryBothDescription => 'Expenses and income';

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
  String get editTransactionTitle => 'Edit transaction';

  @override
  String get transactionsTitle => 'Movements';

  @override
  String get viewTransactions => 'View movements';

  @override
  String get filterTransactionsTitle => 'Filter movements';

  @override
  String get transactionTypeFilter => 'Type';

  @override
  String get allOption => 'All';

  @override
  String get allWallets => 'All wallets';

  @override
  String get allCategories => 'All categories';

  @override
  String get periodFilter => 'Period';

  @override
  String get allTime => 'All time';

  @override
  String get currentMonth => 'This month';

  @override
  String get monthlyIncome => 'Income';

  @override
  String get monthlyExpenses => 'Expenses';

  @override
  String get monthlyNet => 'Net';

  @override
  String get noMonthlyActivity => 'No income or expenses recorded this month.';

  @override
  String get loadMonthlySummaryError =>
      'We couldn\'t load this month\'s summary.';

  @override
  String get customRange => 'Custom';

  @override
  String get resetFilters => 'Reset';

  @override
  String get applyFilters => 'Apply';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get noFilteredTransactionsTitle => 'No movements match';

  @override
  String get noFilteredTransactionsBody =>
      'Try changing or clearing some filters.';

  @override
  String get noTransactionsTitle => 'You don\'t have any movements yet';

  @override
  String get noTransactionsBody =>
      'The expenses, income, and transfers you record will appear here.';

  @override
  String get expense => 'Expense';

  @override
  String get income => 'Income';

  @override
  String get transfer => 'Transfer';

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
      'You need at least one active category compatible with this transaction type.';

  @override
  String get saveTransactionError =>
      'We couldn\'t save the transaction. Please try again.';

  @override
  String get transferBetweenWallets => 'Transfer between wallets';

  @override
  String get newTransferTitle => 'New transfer';

  @override
  String get sourceWalletLabel => 'From wallet';

  @override
  String get destinationWalletLabel => 'To wallet';

  @override
  String get sourceAmountLabel => 'Amount sent';

  @override
  String get destinationAmountLabel => 'Amount received';

  @override
  String get transferAmountInvalid => 'Enter an amount greater than zero.';

  @override
  String get transferNeedsWallets =>
      'You need at least two active wallets to make a transfer.';

  @override
  String get crossCurrencyTransferHint =>
      'Enter the amount that will arrive in the destination currency.';

  @override
  String get useExchangeRate => 'Use conversion factor';

  @override
  String get exchangeRateLabel => 'Conversion factor';

  @override
  String get exchangeRateInvalid =>
      'Enter a conversion factor greater than zero.';

  @override
  String get approximateExchangeRateWarning =>
      'This factor is approximate and may be outdated. Verify that it is correct before saving.';

  @override
  String get lastSavedExchangeRate =>
      'The last factor recorded for this currency pair is used as a reference.';

  @override
  String get noSavedExchangeRate =>
      'There is no saved factor for this currency pair yet.';

  @override
  String get calculatedDestinationAmount => 'Calculated amount';

  @override
  String get saveTransferError =>
      'We couldn\'t save the transfer. Please try again.';

  @override
  String get deleteTransactionTitle => 'Delete transaction';

  @override
  String get deleteTransactionConfirmation =>
      'This will delete the transaction and change the balance. It can\'t be undone.';

  @override
  String get deleteTransactionError =>
      'We couldn\'t delete the transaction. Please try again.';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get unknownWallet => 'Unknown wallet';

  @override
  String get unknownCategory => 'Unknown category';

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
