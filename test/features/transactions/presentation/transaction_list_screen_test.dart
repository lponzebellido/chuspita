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

    await pumpApp(tester, repository: repository, transaction: transaction);
    await tester.tap(find.text('Ver movimientos'));
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

    await pumpApp(tester, repository: repository, transaction: transaction);
    await tester.tap(find.text('Ver movimientos'));
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
}

Future<void> pumpApp(
  WidgetTester tester, {
  required FakeTransactionRepository repository,
  required Transaction transaction,
}) async {
  final wallet = buildWallet();
  final category = buildCategory();
  final summary = BalanceSummary(
    byWallet: {wallet.id: wallet.initialBalance},
    byCurrency: {wallet.currency: wallet.initialBalance},
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        balanceSummaryProvider.overrideWithValue(AsyncData(summary)),
        walletsProvider.overrideWithValue(AsyncData([wallet])),
        categoriesProvider.overrideWithValue(AsyncData([category])),
        transactionsProvider.overrideWithValue(AsyncData([transaction])),
        transactionRepositoryProvider.overrideWithValue(repository),
      ],
      child: const ChuspitaApp(locale: Locale('es')),
    ),
  );
  await tester.pump();
}

Wallet buildWallet() {
  return Wallet(
    id: WalletId('wallet-1'),
    name: 'Efectivo',
    initialBalance: const Money(minorUnits: 0, currency: Currency.eur),
  );
}

Category buildCategory() {
  return Category(
    id: CategoryId('category-1'),
    name: 'Alimentación',
    color: ArgbColor(0xFFF28C28),
  );
}

Transaction buildTransaction() {
  return Transaction(
    id: TransactionId('transaction-1'),
    type: TransactionType.expense,
    amount: const Money(minorUnits: 1250, currency: Currency.eur),
    walletId: WalletId('wallet-1'),
    categoryId: CategoryId('category-1'),
    occurredOn: LocalDate(year: 2026, month: 8, day: 24),
    note: 'Almuerzo',
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
