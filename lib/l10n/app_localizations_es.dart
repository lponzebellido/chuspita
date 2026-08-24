// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Chuspita';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get languageSettingsTitle => 'Idioma';

  @override
  String get appearanceSettingsTitle => 'Apariencia';

  @override
  String get systemOption => 'Sistema';

  @override
  String get spanishLanguage => 'Español';

  @override
  String get englishLanguage => 'Inglés';

  @override
  String get lightTheme => 'Claro';

  @override
  String get darkTheme => 'Oscuro';

  @override
  String get saveSettingsError =>
      'No pudimos guardar la configuración. Inténtalo nuevamente.';

  @override
  String get loadSettingsError => 'No pudimos cargar la configuración.';

  @override
  String get balanceByCurrency => 'Balance por moneda';

  @override
  String get noWalletsTitle => 'Aún no tienes monederos';

  @override
  String get noWalletsBody =>
      'Tu balance aparecerá aquí cuando crees el primero.';

  @override
  String get addWallet => 'Añadir monedero';

  @override
  String get manageWallets => 'Gestionar monederos';

  @override
  String get manageCategories => 'Gestionar categorías';

  @override
  String get categoriesTitle => 'Categorías';

  @override
  String get addCategory => 'Añadir categoría';

  @override
  String get newCategoryTitle => 'Nueva categoría';

  @override
  String get editCategoryTitle => 'Editar categoría';

  @override
  String get categoryNameLabel => 'Nombre';

  @override
  String get categoryNameHint => 'Por ejemplo: Alimentación';

  @override
  String get categoryNameRequired => 'Escribe un nombre para la categoría.';

  @override
  String get categoryColorLabel => 'Color';

  @override
  String get noCategoriesTitle => 'Aún no tienes categorías';

  @override
  String get saveCategoryError =>
      'No pudimos guardar la categoría. Inténtalo nuevamente.';

  @override
  String get addTransaction => 'Añadir movimiento';

  @override
  String get newTransactionTitle => 'Nuevo movimiento';

  @override
  String get editTransactionTitle => 'Editar movimiento';

  @override
  String get transactionsTitle => 'Movimientos';

  @override
  String get viewTransactions => 'Ver movimientos';

  @override
  String get noTransactionsTitle => 'Aún no tienes movimientos';

  @override
  String get noTransactionsBody =>
      'Los gastos e ingresos que registres aparecerán aquí.';

  @override
  String get expense => 'Gasto';

  @override
  String get income => 'Ingreso';

  @override
  String get amountLabel => 'Cantidad';

  @override
  String get walletLabel => 'Monedero';

  @override
  String get categoryLabel => 'Categoría';

  @override
  String get dateLabel => 'Fecha';

  @override
  String get noteLabel => 'Nota opcional';

  @override
  String get noteHint => 'Por ejemplo: Almuerzo';

  @override
  String get transactionAmountInvalid => 'Escribe una cantidad mayor que cero.';

  @override
  String get transactionNeedsWallet =>
      'Necesitas al menos un monedero activo para registrar un movimiento.';

  @override
  String get transactionNeedsCategory =>
      'Necesitas al menos una categoría activa para registrar un movimiento.';

  @override
  String get saveTransactionError =>
      'No pudimos guardar el movimiento. Inténtalo nuevamente.';

  @override
  String get deleteTransactionTitle => 'Eliminar movimiento';

  @override
  String get deleteTransactionConfirmation =>
      'Esta acción eliminará el movimiento y modificará el balance. No se puede deshacer.';

  @override
  String get deleteTransactionError =>
      'No pudimos eliminar el movimiento. Inténtalo nuevamente.';

  @override
  String get delete => 'Eliminar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get unknownWallet => 'Monedero desconocido';

  @override
  String get unknownCategory => 'Categoría desconocida';

  @override
  String get walletsTitle => 'Monederos';

  @override
  String get editWalletTitle => 'Editar monedero';

  @override
  String get edit => 'Editar';

  @override
  String get archive => 'Archivar';

  @override
  String get restore => 'Restaurar';

  @override
  String get archived => 'Archivado';

  @override
  String get walletCurrencyChangeNotAllowed =>
      'No puedes cambiar la moneda porque este monedero ya tiene movimientos financieros.';

  @override
  String get loadDataError => 'No pudimos cargar tus datos.';

  @override
  String get retry => 'Reintentar';

  @override
  String get newWalletTitle => 'Nuevo monedero';

  @override
  String get walletNameLabel => 'Nombre';

  @override
  String get walletNameHint => 'Por ejemplo: Efectivo';

  @override
  String get currencyLabel => 'Moneda';

  @override
  String get initialBalanceLabel => 'Saldo inicial';

  @override
  String get save => 'Guardar';

  @override
  String get walletNameRequired => 'Escribe un nombre para el monedero.';

  @override
  String get initialBalanceInvalid =>
      'Escribe una cantidad válida para esta moneda.';

  @override
  String get saveWalletError =>
      'No pudimos guardar el monedero. Inténtalo nuevamente.';
}
