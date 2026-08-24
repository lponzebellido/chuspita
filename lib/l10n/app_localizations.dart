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
