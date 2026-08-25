import 'package:chuspita/app/app.dart';
import 'package:chuspita/app/providers.dart';
import 'package:chuspita/core/color/argb_color.dart';
import 'package:chuspita/core/currency/currency.dart';
import 'package:chuspita/core/date/local_date.dart';
import 'package:chuspita/core/money/money.dart';
import 'package:chuspita/features/categories/domain/category.dart';
import 'package:chuspita/features/categories/domain/category_id.dart';
import 'package:chuspita/features/transactions/domain/transaction.dart';
import 'package:chuspita/features/transactions/domain/transaction_id.dart';
import 'package:chuspita/features/transactions/domain/transaction_repository.dart';
import 'package:chuspita/features/transfers/domain/transfer.dart';
import 'package:chuspita/features/transfers/domain/transfer_id.dart';
import 'package:chuspita/features/transfers/domain/transfer_repository.dart';
import 'package:chuspita/features/wallets/application/balance_summary.dart';
import 'package:chuspita/features/wallets/domain/wallet.dart';
import 'package:chuspita/features/wallets/domain/wallet_id.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the transaction history and edits a transaction', (
    tester,
  ) async {
    final transaction = buildTransaction();
    final repository = FakeTransactionRepository([transaction]);

    await pumpApp(tester, repository: repository);
    await tester.tap(find.widgetWithText(OutlinedButton, 'Ver movimientos'));
    await tester.pumpAndSettle();

    expect(find.text('Movimientos'), findsOneWidget);
    expect(find.text('Alimentación'), findsOneWidget);
    expect(find.textContaining('Almuerzo · Efectivo'), findsOneWidget);
    expect(find.text('-12,50 EUR'), findsOneWidget);

    await tester.tap(find.text('Alimentación'));
    await tester.pumpAndSettle();

    expect(find.text('Editar movimiento'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).first, '20,00');
    await tester.tap(find.widgetWithText(FilledButton, 'Guardar'));
    await tester.pumpAndSettle();

    expect(repository.savedTransaction, isNotNull);
    expect(repository.savedTransaction!.id, transaction.id);
    expect(
      repository.savedTransaction!.amount,
      const Money(minorUnits: 2000, currency: Currency.eur),
    );
  });

  testWidgets('deletes a transaction after explicit confirmation', (
    tester,
  ) async {
    final transaction = buildTransaction();
    final repository = FakeTransactionRepository([transaction]);

    await pumpApp(tester, repository: repository);
    await tester.tap(find.widgetWithText(OutlinedButton, 'Ver movimientos'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Alimentación'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Eliminar'));
    await tester.pumpAndSettle();

    expect(find.text('Eliminar movimiento'), findsOneWidget);
    expect(
      find.text(
        'Esta acción eliminará el movimiento y modificará el balance. '
        'No se puede deshacer.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Eliminar'));
    await tester.pumpAndSettle();

    expect(repository.deletedId, transaction.id);
  });

  testWidgets('filters transaction history by type', (tester) async {
    final expense = buildTransaction();
    final income = buildTransaction(
      id: 'transaction-2',
      type: TransactionType.income,
      amountMinor: 3000,
      note: 'Sueldo',
    );
    final repository = FakeTransactionRepository([expense, income]);

    await pumpApp(tester, repository: repository);
    await tester.tap(find.widgetWithText(OutlinedButton, 'Ver movimientos'));
    await tester.pumpAndSettle();

    expect(find.text('-12,50 EUR'), findsOneWidget);
    expect(find.text('+30,00 EUR'), findsOneWidget);

    await tester.tap(find.byTooltip('Filtrar movimientos'));
    await tester.pumpAndSettle();

    expect(find.text('Filtrar movimientos'), findsOneWidget);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Ingreso'));
    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Aplicar'));
    await tester.tap(find.widgetWithText(FilledButton, 'Aplicar'));
    await tester.pumpAndSettle();

    expect(find.text('-12,50 EUR'), findsNothing);
    expect(find.text('+30,00 EUR'), findsOneWidget);
    expect(find.text('Quitar filtros'), findsOneWidget);

    await tester.tap(find.text('Quitar filtros'));
    await tester.pump();

    expect(find.text('-12,50 EUR'), findsOneWidget);
    expect(find.text('+30,00 EUR'), findsOneWidget);
  });

  testWidgets('shows and filters a transfer as a neutral movement', (
    tester,
  ) async {
    final sourceWallet = buildWallet();
    final destinationWallet = buildWallet(
      id: 'wallet-2',
      name: 'Ahorros',
      currency: Currency.pen,
    );
    final repository = FakeTransactionRepository([buildTransaction()]);
    final transfer = Transfer(
      id: TransferId('transfer-1'),
      sourceWalletId: sourceWallet.id,
      destinationWalletId: destinationWallet.id,
      sourceAmount: const Money(minorUnits: 1000, currency: Currency.eur),
      destinationAmount: const Money(minorUnits: 4000, currency: Currency.pen),
      occurredOn: LocalDate(year: 2026, month: 8, day: 24),
      note: 'Cambio de moneda',
    );

    await pumpApp(
      tester,
      repository: repository,
      wallets: [sourceWallet, destinationWallet],
      transfers: [transfer],
    );
    await tester.tap(find.widgetWithText(OutlinedButton, 'Ver movimientos'));
    await tester.pumpAndSettle();

    expect(find.text('Transferencia'), findsOneWidget);
    expect(
      find.textContaining('Cambio de moneda · Efectivo → Ahorros'),
      findsOneWidget,
    );
    expect(find.text('−10,00 EUR'), findsOneWidget);
    expect(find.text('+40,00 PEN'), findsOneWidget);
    expect(find.text('-12,50 EUR'), findsOneWidget);

    await tester.tap(find.byTooltip('Filtrar movimientos'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, 'Transferencia'));
    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Aplicar'));
    await tester.tap(find.widgetWithText(FilledButton, 'Aplicar'));
    await tester.pumpAndSettle();

    expect(find.text('Transferencia'), findsOneWidget);
    expect(find.text('-12,50 EUR'), findsNothing);

    await tester.tap(find.text('Transferencia'));
    await tester.pumpAndSettle();

    expect(find.text('Monedero de origen'), findsOneWidget);
    expect(find.text('Monedero de destino'), findsOneWidget);
    expect(find.text('Efectivo'), findsOneWidget);
    expect(find.text('Ahorros'), findsOneWidget);
    expect(find.text('Cambio de moneda'), findsOneWidget);
  });

  testWidgets('deletes a transfer after explicit confirmation', (tester) async {
    final sourceWallet = buildWallet();
    final destinationWallet = buildWallet(
      id: 'wallet-2',
      name: 'Ahorros',
      currency: Currency.pen,
    );
    final transfer = Transfer(
      id: TransferId('transfer-1'),
      sourceWalletId: sourceWallet.id,
      destinationWalletId: destinationWallet.id,
      sourceAmount: const Money(minorUnits: 1000, currency: Currency.eur),
      destinationAmount: const Money(minorUnits: 4000, currency: Currency.pen),
      occurredOn: LocalDate(year: 2026, month: 8, day: 24),
    );
    final transferRepository = FakeTransferRepository([transfer]);

    await pumpApp(
      tester,
      repository: FakeTransactionRepository([]),
      wallets: [sourceWallet, destinationWallet],
      transfers: [transfer],
      transferRepository: transferRepository,
    );
    await tester.tap(find.widgetWithText(OutlinedButton, 'Ver movimientos'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Transferencia'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Eliminar'));
    await tester.pumpAndSettle();

    expect(find.text('Eliminar transferencia'), findsOneWidget);
    expect(
      find.text(
        'Esta acción eliminará la transferencia y modificará el balance de '
        'ambos monederos. No se puede deshacer.',
      ),
      findsOneWidget,
    );

    final confirmationButton = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.widgetWithText(FilledButton, 'Eliminar'),
    );
    await tester.tap(confirmationButton);
    await tester.pumpAndSettle();

    expect(transferRepository.deletedId, transfer.id);
    expect(find.text('Monedero de origen'), findsNothing);
  });

  testWidgets('groups movements by date in both sort orders', (tester) async {
    final currentDate = LocalDate(year: 2026, month: 8, day: 24);
    final yesterday = LocalDate(year: 2026, month: 8, day: 23);
    final olderDate = LocalDate(year: 2026, month: 8, day: 20);
    final sourceWallet = buildWallet();
    final destinationWallet = buildWallet(
      id: 'wallet-2',
      name: 'Ahorros',
      currency: Currency.pen,
    );
    final repository = FakeTransactionRepository([
      buildTransaction(id: 'today', note: 'Compra de hoy'),
      buildTransaction(
        id: 'yesterday',
        note: 'Compra de ayer',
        occurredOn: yesterday,
      ),
      buildTransaction(
        id: 'older',
        note: 'Compra anterior',
        occurredOn: olderDate,
      ),
    ]);
    final transfer = Transfer(
      id: TransferId('yesterday-transfer'),
      sourceWalletId: sourceWallet.id,
      destinationWalletId: destinationWallet.id,
      sourceAmount: const Money(minorUnits: 1000, currency: Currency.eur),
      destinationAmount: const Money(minorUnits: 4000, currency: Currency.pen),
      occurredOn: yesterday,
      note: 'Transferencia de ayer',
    );

    await pumpApp(
      tester,
      repository: repository,
      wallets: [sourceWallet, destinationWallet],
      transfers: [transfer],
      currentDate: currentDate,
    );
    await tester.tap(find.widgetWithText(OutlinedButton, 'Ver movimientos'));
    await tester.pumpAndSettle();

    final todayHeader = find.byKey(
      const ValueKey('movement-date-header-2026-08-24'),
    );
    final yesterdayHeader = find.byKey(
      const ValueKey('movement-date-header-2026-08-23'),
    );
    final olderHeader = find.byKey(
      const ValueKey('movement-date-header-2026-08-20'),
    );

    expect(find.text('Hoy'), findsOneWidget);
    expect(find.text('Ayer'), findsOneWidget);
    expect(todayHeader, findsOneWidget);
    expect(yesterdayHeader, findsOneWidget);
    expect(olderHeader, findsOneWidget);
    expect(find.text('Transferencia'), findsOneWidget);
    expect(
      tester.getTopLeft(todayHeader).dy,
      lessThan(tester.getTopLeft(yesterdayHeader).dy),
    );
    expect(
      tester.getTopLeft(yesterdayHeader).dy,
      lessThan(tester.getTopLeft(olderHeader).dy),
    );

    await tester.tap(find.byTooltip('Filtrar movimientos'));
    await tester.pumpAndSettle();
    final oldestFirst = find.widgetWithText(ChoiceChip, 'Más antiguos primero');
    await tester.ensureVisible(oldestFirst);
    await tester.pumpAndSettle();
    await tester.tap(oldestFirst);
    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Aplicar'));
    await tester.tap(find.widgetWithText(FilledButton, 'Aplicar'));
    await tester.pumpAndSettle();

    expect(
      tester.getTopLeft(olderHeader).dy,
      lessThan(tester.getTopLeft(yesterdayHeader).dy),
    );
    expect(
      tester.getTopLeft(yesterdayHeader).dy,
      lessThan(tester.getTopLeft(todayHeader).dy),
    );
  });
}

Future<void> pumpApp(
  WidgetTester tester, {
  required FakeTransactionRepository repository,
  List<Wallet>? wallets,
  List<Transfer> transfers = const [],
  TransferRepository? transferRepository,
  LocalDate? currentDate,
}) async {
  final walletValues = wallets ?? [buildWallet()];
  final category = buildCategory();
  final summary = BalanceSummary(
    byWallet: {
      for (final wallet in walletValues) wallet.id: wallet.initialBalance,
    },
    byCurrency: {
      for (final wallet in walletValues) wallet.currency: wallet.initialBalance,
    },
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        balanceSummaryProvider.overrideWithValue(AsyncData(summary)),
        walletsProvider.overrideWithValue(AsyncData(walletValues)),
        categoriesProvider.overrideWithValue(AsyncData([category])),
        transactionsProvider.overrideWithValue(
          AsyncData(repository.transactions),
        ),
        transfersProvider.overrideWithValue(AsyncData(transfers)),
        if (transferRepository != null)
          transferRepositoryProvider.overrideWithValue(transferRepository),
        currentDateProvider.overrideWithValue(
          currentDate ?? LocalDate(year: 2026, month: 8, day: 24),
        ),
        transactionRepositoryProvider.overrideWithValue(repository),
      ],
      child: const ChuspitaApp(locale: Locale('es')),
    ),
  );
  await tester.pump();
}

Wallet buildWallet({
  String id = 'wallet-1',
  String name = 'Efectivo',
  Currency currency = Currency.eur,
}) {
  return Wallet(
    id: WalletId(id),
    name: name,
    initialBalance: Money(minorUnits: 0, currency: currency),
  );
}

Category buildCategory() {
  return Category(
    id: CategoryId('category-1'),
    name: 'Alimentación',
    color: ArgbColor(0xFFF28C28),
  );
}

Transaction buildTransaction({
  String id = 'transaction-1',
  TransactionType type = TransactionType.expense,
  int amountMinor = 1250,
  String note = 'Almuerzo',
  LocalDate? occurredOn,
}) {
  return Transaction(
    id: TransactionId(id),
    type: type,
    amount: Money(minorUnits: amountMinor, currency: Currency.eur),
    walletId: WalletId('wallet-1'),
    categoryId: CategoryId('category-1'),
    occurredOn: occurredOn ?? LocalDate(year: 2026, month: 8, day: 24),
    note: note,
  );
}

final class FakeTransactionRepository implements TransactionRepository {
  FakeTransactionRepository(this.transactions);

  final List<Transaction> transactions;
  Transaction? savedTransaction;
  TransactionId? deletedId;

  @override
  Future<void> delete(TransactionId id) async {
    deletedId = id;
  }

  @override
  Future<List<Transaction>> getAll() async => transactions;

  @override
  Future<Transaction?> getById(TransactionId id) async => null;

  @override
  Future<void> save(Transaction transaction) async {
    savedTransaction = transaction;
  }
}

final class FakeTransferRepository implements TransferRepository {
  FakeTransferRepository(this.transfers);

  final List<Transfer> transfers;
  TransferId? deletedId;

  @override
  Future<void> delete(TransferId id) async {
    deletedId = id;
  }

  @override
  Future<List<Transfer>> getAll() async => transfers;

  @override
  Future<Transfer?> getById(TransferId id) async => null;

  @override
  Future<void> save(Transfer transfer) async {}
}
