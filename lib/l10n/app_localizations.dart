import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'Chuspita'**
  String get appName;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @languageSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSettingsTitle;

  /// No description provided for @appearanceSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceSettingsTitle;

  /// No description provided for @systemOption.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemOption;

  /// No description provided for @spanishLanguage.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanishLanguage;

  /// No description provided for @englishLanguage.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get englishLanguage;

  /// No description provided for @lightTheme.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkTheme;

  /// No description provided for @saveSettingsError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t save the settings. Please try again.'**
  String get saveSettingsError;

  /// No description provided for @loadSettingsError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load the settings.'**
  String get loadSettingsError;

  /// No description provided for @backupSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get backupSettingsTitle;

  /// No description provided for @createBackup.
  ///
  /// In en, this message translates to:
  /// **'Create backup'**
  String get createBackup;

  /// No description provided for @backupDescription.
  ///
  /// In en, this message translates to:
  /// **'Save a restorable copy of your wallets, categories, and movements. Keep this file private.'**
  String get backupDescription;

  /// No description provided for @createBackupError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t create the backup. Please try again.'**
  String get createBackupError;

  /// No description provided for @restoreBackup.
  ///
  /// In en, this message translates to:
  /// **'Restore backup'**
  String get restoreBackup;

  /// No description provided for @restoreBackupDescription.
  ///
  /// In en, this message translates to:
  /// **'Replace the current financial data with a Chuspita backup.'**
  String get restoreBackupDescription;

  /// No description provided for @restoreBackupTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore backup?'**
  String get restoreBackupTitle;

  /// No description provided for @restoreBackupConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Your current wallets, categories, and movements will be replaced with the contents of the selected backup.'**
  String get restoreBackupConfirmation;

  /// No description provided for @restoreBackupSuccess.
  ///
  /// In en, this message translates to:
  /// **'The backup was restored.'**
  String get restoreBackupSuccess;

  /// No description provided for @invalidBackupError.
  ///
  /// In en, this message translates to:
  /// **'This file isn\'t a valid or compatible Chuspita backup.'**
  String get invalidBackupError;

  /// No description provided for @restoreBackupError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t restore the backup. Your previous data was preserved.'**
  String get restoreBackupError;

  /// No description provided for @balanceByCurrency.
  ///
  /// In en, this message translates to:
  /// **'Balance by currency'**
  String get balanceByCurrency;

  /// No description provided for @noWalletsTitle.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any wallets yet'**
  String get noWalletsTitle;

  /// No description provided for @noWalletsBody.
  ///
  /// In en, this message translates to:
  /// **'Your balance will appear here after you create the first one.'**
  String get noWalletsBody;

  /// No description provided for @noActiveWalletsTitle.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any active wallets'**
  String get noActiveWalletsTitle;

  /// No description provided for @noActiveWalletsBody.
  ///
  /// In en, this message translates to:
  /// **'Your archived wallets are still available in wallet management.'**
  String get noActiveWalletsBody;

  /// No description provided for @addWallet.
  ///
  /// In en, this message translates to:
  /// **'Add wallet'**
  String get addWallet;

  /// No description provided for @manageWallets.
  ///
  /// In en, this message translates to:
  /// **'Manage wallets'**
  String get manageWallets;

  /// No description provided for @manageCategories.
  ///
  /// In en, this message translates to:
  /// **'Manage categories'**
  String get manageCategories;

  /// No description provided for @categoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categoriesTitle;

  /// No description provided for @addCategory.
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get addCategory;

  /// No description provided for @newCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'New category'**
  String get newCategoryTitle;

  /// No description provided for @editCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit category'**
  String get editCategoryTitle;

  /// No description provided for @categoryNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get categoryNameLabel;

  /// No description provided for @categoryNameHint.
  ///
  /// In en, this message translates to:
  /// **'For example: Food'**
  String get categoryNameHint;

  /// No description provided for @categoryNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a category name.'**
  String get categoryNameRequired;

  /// No description provided for @categoryApplicabilityLabel.
  ///
  /// In en, this message translates to:
  /// **'Use for'**
  String get categoryApplicabilityLabel;

  /// No description provided for @categoryExpenseOption.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get categoryExpenseOption;

  /// No description provided for @categoryIncomeOption.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get categoryIncomeOption;

  /// No description provided for @categoryBothOption.
  ///
  /// In en, this message translates to:
  /// **'Both'**
  String get categoryBothOption;

  /// No description provided for @categoryBothDescription.
  ///
  /// In en, this message translates to:
  /// **'Expenses and income'**
  String get categoryBothDescription;

  /// No description provided for @categoryColorLabel.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get categoryColorLabel;

  /// No description provided for @noCategoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any categories yet'**
  String get noCategoriesTitle;

  /// No description provided for @saveCategoryError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t save the category. Please try again.'**
  String get saveCategoryError;

  /// No description provided for @addTransaction.
  ///
  /// In en, this message translates to:
  /// **'Add transaction'**
  String get addTransaction;

  /// No description provided for @newTransactionTitle.
  ///
  /// In en, this message translates to:
  /// **'New transaction'**
  String get newTransactionTitle;

  /// No description provided for @editTransactionTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit transaction'**
  String get editTransactionTitle;

  /// No description provided for @transactionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Movements'**
  String get transactionsTitle;

  /// No description provided for @viewTransactions.
  ///
  /// In en, this message translates to:
  /// **'View movements'**
  String get viewTransactions;

  /// No description provided for @filterTransactionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Filter movements'**
  String get filterTransactionsTitle;

  /// No description provided for @transactionTypeFilter.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get transactionTypeFilter;

  /// No description provided for @allOption.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allOption;

  /// No description provided for @allWallets.
  ///
  /// In en, this message translates to:
  /// **'All wallets'**
  String get allWallets;

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get allCategories;

  /// No description provided for @periodFilter.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get periodFilter;

  /// No description provided for @allTime.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get allTime;

  /// No description provided for @currentMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get currentMonth;

  /// No description provided for @currentDay.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get currentDay;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @currentWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get currentWeek;

  /// No description provided for @currentYear.
  ///
  /// In en, this message translates to:
  /// **'This year'**
  String get currentYear;

  /// No description provided for @statisticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statisticsTitle;

  /// No description provided for @viewStatistics.
  ///
  /// In en, this message translates to:
  /// **'View statistics'**
  String get viewStatistics;

  /// No description provided for @loadStatisticsError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load the statistics.'**
  String get loadStatisticsError;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export data'**
  String get exportData;

  /// No description provided for @exportXlsx.
  ///
  /// In en, this message translates to:
  /// **'Export XLSX'**
  String get exportXlsx;

  /// No description provided for @exportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get exportCsv;

  /// No description provided for @exportDataError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t export the file. Please try again.'**
  String get exportDataError;

  /// No description provided for @incomeVsExpensesTitle.
  ///
  /// In en, this message translates to:
  /// **'Income vs. expenses'**
  String get incomeVsExpensesTitle;

  /// No description provided for @noPeriodActivity.
  ///
  /// In en, this message translates to:
  /// **'There is no income or expense activity in this period.'**
  String get noPeriodActivity;

  /// No description provided for @spendingMetricsTitle.
  ///
  /// In en, this message translates to:
  /// **'Spending metrics'**
  String get spendingMetricsTitle;

  /// No description provided for @noExpenseMetrics.
  ///
  /// In en, this message translates to:
  /// **'There are no expenses to analyze in this period.'**
  String get noExpenseMetrics;

  /// No description provided for @expenseCountMetric.
  ///
  /// In en, this message translates to:
  /// **'Recorded expenses'**
  String get expenseCountMetric;

  /// No description provided for @averageExpenseMetric.
  ///
  /// In en, this message translates to:
  /// **'Average per expense'**
  String get averageExpenseMetric;

  /// No description provided for @largestExpenseMetric.
  ///
  /// In en, this message translates to:
  /// **'Largest expense'**
  String get largestExpenseMetric;

  /// No description provided for @topCategoryMetric.
  ///
  /// In en, this message translates to:
  /// **'Top category'**
  String get topCategoryMetric;

  /// No description provided for @periodComparisonTitle.
  ///
  /// In en, this message translates to:
  /// **'Compared with the previous period'**
  String get periodComparisonTitle;

  /// No description provided for @previousPeriod.
  ///
  /// In en, this message translates to:
  /// **'Previous period'**
  String get previousPeriod;

  /// No description provided for @noPeriodComparison.
  ///
  /// In en, this message translates to:
  /// **'There is no activity to compare in these periods.'**
  String get noPeriodComparison;

  /// No description provided for @noPreviousReference.
  ///
  /// In en, this message translates to:
  /// **'No previous reference'**
  String get noPreviousReference;

  /// No description provided for @unchangedFromPrevious.
  ///
  /// In en, this message translates to:
  /// **'No change'**
  String get unchangedFromPrevious;

  /// No description provided for @moreThanPrevious.
  ///
  /// In en, this message translates to:
  /// **'more'**
  String get moreThanPrevious;

  /// No description provided for @lessThanPrevious.
  ///
  /// In en, this message translates to:
  /// **'less'**
  String get lessThanPrevious;

  /// No description provided for @expenseTrendTitle.
  ///
  /// In en, this message translates to:
  /// **'Spending over time'**
  String get expenseTrendTitle;

  /// No description provided for @noExpenseTrend.
  ///
  /// In en, this message translates to:
  /// **'There are no expenses to chart in this period.'**
  String get noExpenseTrend;

  /// No description provided for @expenseTrendGroupedByDay.
  ///
  /// In en, this message translates to:
  /// **'Grouped by day'**
  String get expenseTrendGroupedByDay;

  /// No description provided for @expenseTrendGroupedByWeek.
  ///
  /// In en, this message translates to:
  /// **'Grouped by week'**
  String get expenseTrendGroupedByWeek;

  /// No description provided for @expenseTrendGroupedByMonth.
  ///
  /// In en, this message translates to:
  /// **'Grouped by month'**
  String get expenseTrendGroupedByMonth;

  /// No description provided for @monthlyIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get monthlyIncome;

  /// No description provided for @monthlyExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get monthlyExpenses;

  /// No description provided for @monthlyNet.
  ///
  /// In en, this message translates to:
  /// **'Net'**
  String get monthlyNet;

  /// No description provided for @noMonthlyActivity.
  ///
  /// In en, this message translates to:
  /// **'No income or expenses recorded this month.'**
  String get noMonthlyActivity;

  /// No description provided for @loadMonthlySummaryError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load this month\'s summary.'**
  String get loadMonthlySummaryError;

  /// No description provided for @categorySpendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Spending by category'**
  String get categorySpendingTitle;

  /// No description provided for @noCategorySpending.
  ///
  /// In en, this message translates to:
  /// **'No expenses recorded this month.'**
  String get noCategorySpending;

  /// No description provided for @loadCategorySpendingError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load spending by category.'**
  String get loadCategorySpendingError;

  /// No description provided for @customRange.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get customRange;

  /// No description provided for @resetFilters.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetFilters;

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get applyFilters;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFilters;

  /// No description provided for @noFilteredTransactionsTitle.
  ///
  /// In en, this message translates to:
  /// **'No movements match'**
  String get noFilteredTransactionsTitle;

  /// No description provided for @noFilteredTransactionsBody.
  ///
  /// In en, this message translates to:
  /// **'Try changing or clearing some filters.'**
  String get noFilteredTransactionsBody;

  /// No description provided for @noTransactionsTitle.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any movements yet'**
  String get noTransactionsTitle;

  /// No description provided for @noTransactionsBody.
  ///
  /// In en, this message translates to:
  /// **'The expenses, income, and transfers you record will appear here.'**
  String get noTransactionsBody;

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @transfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get transfer;

  /// No description provided for @amountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amountLabel;

  /// No description provided for @walletLabel.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get walletLabel;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateLabel;

  /// No description provided for @timeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get timeLabel;

  /// No description provided for @sortOrderLabel.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get sortOrderLabel;

  /// No description provided for @newestFirst.
  ///
  /// In en, this message translates to:
  /// **'Newest first'**
  String get newestFirst;

  /// No description provided for @oldestFirst.
  ///
  /// In en, this message translates to:
  /// **'Oldest first'**
  String get oldestFirst;

  /// No description provided for @noteLabel.
  ///
  /// In en, this message translates to:
  /// **'Optional note'**
  String get noteLabel;

  /// No description provided for @noteHint.
  ///
  /// In en, this message translates to:
  /// **'For example: Lunch'**
  String get noteHint;

  /// No description provided for @transactionAmountInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount greater than zero.'**
  String get transactionAmountInvalid;

  /// No description provided for @transactionNeedsWallet.
  ///
  /// In en, this message translates to:
  /// **'You need at least one active wallet to record a transaction.'**
  String get transactionNeedsWallet;

  /// No description provided for @transactionNeedsCategory.
  ///
  /// In en, this message translates to:
  /// **'You need at least one active category compatible with this transaction type.'**
  String get transactionNeedsCategory;

  /// No description provided for @saveTransactionError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t save the transaction. Please try again.'**
  String get saveTransactionError;

  /// No description provided for @transferBetweenWallets.
  ///
  /// In en, this message translates to:
  /// **'Transfer between wallets'**
  String get transferBetweenWallets;

  /// No description provided for @newTransferTitle.
  ///
  /// In en, this message translates to:
  /// **'New transfer'**
  String get newTransferTitle;

  /// No description provided for @editTransferTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit transfer'**
  String get editTransferTitle;

  /// No description provided for @sourceWalletLabel.
  ///
  /// In en, this message translates to:
  /// **'From wallet'**
  String get sourceWalletLabel;

  /// No description provided for @destinationWalletLabel.
  ///
  /// In en, this message translates to:
  /// **'To wallet'**
  String get destinationWalletLabel;

  /// No description provided for @sourceAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount sent'**
  String get sourceAmountLabel;

  /// No description provided for @destinationAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount received'**
  String get destinationAmountLabel;

  /// No description provided for @transferAmountInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount greater than zero.'**
  String get transferAmountInvalid;

  /// No description provided for @transferNeedsWallets.
  ///
  /// In en, this message translates to:
  /// **'You need at least two active wallets to make a transfer.'**
  String get transferNeedsWallets;

  /// No description provided for @crossCurrencyTransferHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the amount that will arrive in the destination currency.'**
  String get crossCurrencyTransferHint;

  /// No description provided for @useExchangeRate.
  ///
  /// In en, this message translates to:
  /// **'Use conversion factor'**
  String get useExchangeRate;

  /// No description provided for @exchangeRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Conversion factor'**
  String get exchangeRateLabel;

  /// No description provided for @exchangeRateInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a conversion factor greater than zero.'**
  String get exchangeRateInvalid;

  /// No description provided for @approximateExchangeRateWarning.
  ///
  /// In en, this message translates to:
  /// **'This factor is approximate and may be outdated. Verify that it is correct before saving.'**
  String get approximateExchangeRateWarning;

  /// No description provided for @lastSavedExchangeRate.
  ///
  /// In en, this message translates to:
  /// **'The last factor recorded for this currency pair is used as a reference.'**
  String get lastSavedExchangeRate;

  /// No description provided for @noSavedExchangeRate.
  ///
  /// In en, this message translates to:
  /// **'There is no saved factor for this currency pair yet.'**
  String get noSavedExchangeRate;

  /// No description provided for @calculatedDestinationAmount.
  ///
  /// In en, this message translates to:
  /// **'Calculated amount'**
  String get calculatedDestinationAmount;

  /// No description provided for @saveTransferError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t save the transfer. Please try again.'**
  String get saveTransferError;

  /// No description provided for @deleteTransferTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete transfer'**
  String get deleteTransferTitle;

  /// No description provided for @deleteTransferConfirmation.
  ///
  /// In en, this message translates to:
  /// **'This will delete the transfer and change both wallet balances. It can\'t be undone.'**
  String get deleteTransferConfirmation;

  /// No description provided for @deleteTransferError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t delete the transfer. Please try again.'**
  String get deleteTransferError;

  /// No description provided for @deleteTransactionTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete transaction'**
  String get deleteTransactionTitle;

  /// No description provided for @deleteTransactionConfirmation.
  ///
  /// In en, this message translates to:
  /// **'This will delete the transaction and change the balance. It can\'t be undone.'**
  String get deleteTransactionConfirmation;

  /// No description provided for @deleteTransactionError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t delete the transaction. Please try again.'**
  String get deleteTransactionError;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @unknownWallet.
  ///
  /// In en, this message translates to:
  /// **'Unknown wallet'**
  String get unknownWallet;

  /// No description provided for @unknownCategory.
  ///
  /// In en, this message translates to:
  /// **'Unknown category'**
  String get unknownCategory;

  /// No description provided for @walletsTitle.
  ///
  /// In en, this message translates to:
  /// **'Wallets'**
  String get walletsTitle;

  /// No description provided for @editWalletTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit wallet'**
  String get editWalletTitle;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @archive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archive;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @archived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get archived;

  /// No description provided for @walletCurrencyChangeNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'The currency can\'t change because this wallet already has financial movements.'**
  String get walletCurrencyChangeNotAllowed;

  /// No description provided for @deleteWalletTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete wallet'**
  String get deleteWalletTitle;

  /// No description provided for @deleteWalletConfirmation.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes the wallet and its initial balance. It can\'t be undone.'**
  String get deleteWalletConfirmation;

  /// No description provided for @deleteWalletHasMovements.
  ///
  /// In en, this message translates to:
  /// **'This wallet has financial movements. Archive it to preserve its history.'**
  String get deleteWalletHasMovements;

  /// No description provided for @deleteWalletError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t delete the wallet. Please try again.'**
  String get deleteWalletError;

  /// No description provided for @loadDataError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load your data.'**
  String get loadDataError;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @newWalletTitle.
  ///
  /// In en, this message translates to:
  /// **'New wallet'**
  String get newWalletTitle;

  /// No description provided for @walletNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get walletNameLabel;

  /// No description provided for @walletNameHint.
  ///
  /// In en, this message translates to:
  /// **'For example: Cash'**
  String get walletNameHint;

  /// No description provided for @currencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currencyLabel;

  /// No description provided for @initialBalanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Initial balance'**
  String get initialBalanceLabel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @walletNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a wallet name.'**
  String get walletNameRequired;

  /// No description provided for @initialBalanceInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount for this currency.'**
  String get initialBalanceInvalid;

  /// No description provided for @saveWalletError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t save the wallet. Please try again.'**
  String get saveWalletError;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
