import 'package:chuspita/app/app.dart';
import 'package:chuspita/app/providers.dart';
import 'package:chuspita/core/color/argb_color.dart';
import 'package:chuspita/core/currency/currency.dart';
import 'package:chuspita/core/money/money.dart';
import 'package:chuspita/features/categories/domain/category.dart';
import 'package:chuspita/features/categories/domain/category_applicability.dart';
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
  testWidgets('creates an expense from the main action', (tester) async {
    final wallet = buildWallet();
    final category = buildCategory();
    final repository = FakeTransactionRepository();
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
          transactionRepositoryProvider.overrideWithValue(repository),
          transactionIdGeneratorProvider.overrideWithValue(
            () => 'generated-transaction-id',
          ),
        ],
        child: const ChuspitaApp(locale: Locale('es')),
      ),
    );
    await tester.pump();

    await tester.tap(
      find.widgetWithText(FloatingActionButton, 'Añadir movimiento'),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nuevo movimiento'), findsOneWidget);
    expect(find.text('Gasto'), findsOneWidget);
    expect(find.text('Ingreso'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, '12,50');
    await tester.enterText(find.byType(TextFormField).last, 'Almuerzo');
    await tester.tap(find.widgetWithText(FilledButton, 'Guardar'));
    await tester.pumpAndSettle();

    expect(repository.savedTransaction, isNotNull);
    expect(
      repository.savedTransaction!.id,
      TransactionId('generated-transaction-id'),
    );
    expect(repository.savedTransaction!.type, TransactionType.expense);
    expect(
      repository.savedTransaction!.amount,
      const Money(minorUnits: 1250, currency: Currency.eur),
    );
    expect(repository.savedTransaction!.walletId, wallet.id);
    expect(repository.savedTransaction!.categoryId, category.id);
    expect(repository.savedTransaction!.note, 'Almuerzo');
  });

  testWidgets('requires an active category before recording a transaction', (
    tester,
  ) async {
    final wallet = buildWallet();
    final summary = BalanceSummary(
      byWallet: {wallet.id: wallet.initialBalance},
      byCurrency: {wallet.currency: wallet.initialBalance},
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          balanceSummaryProvider.overrideWithValue(AsyncData(summary)),
          walletsProvider.overrideWithValue(AsyncData([wallet])),
          categoriesProvider.overrideWithValue(const AsyncData([])),
        ],
        child: const ChuspitaApp(locale: Locale('es')),
      ),
    );
    await tester.pump();

    await tester.tap(
      find.widgetWithText(FloatingActionButton, 'Añadir movimiento'),
    );
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Necesitas al menos una categoría activa compatible con este tipo de movimiento.',
      ),
      findsOneWidget,
    );
    expect(find.widgetWithText(FilledButton, 'Guardar'), findsNothing);
  });

  testWidgets('shows only categories compatible with the transaction type', (
    tester,
  ) async {
    final wallet = buildWallet();
    final expenseCategory = buildCategory(
      id: 'expense-category',
      name: 'Alimentación',
      applicability: CategoryApplicability.expense,
    );
    final incomeCategory = buildCategory(
      id: 'income-category',
      name: 'Sueldo',
      applicability: CategoryApplicability.income,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          balanceSummaryProvider.overrideWithValue(
            AsyncData(
              BalanceSummary(
                byWallet: {wallet.id: wallet.initialBalance},
                byCurrency: {wallet.currency: wallet.initialBalance},
              ),
            ),
          ),
          walletsProvider.overrideWithValue(AsyncData([wallet])),
          categoriesProvider.overrideWithValue(
            AsyncData([expenseCategory, incomeCategory]),
          ),
        ],
        child: const ChuspitaApp(locale: Locale('es')),
      ),
    );
    await tester.pump();

    await tester.tap(
      find.widgetWithText(FloatingActionButton, 'Añadir movimiento'),
    );
    await tester.pumpAndSettle();

    expect(find.text('Alimentación'), findsOneWidget);
    expect(find.text('Sueldo'), findsNothing);

    await tester.tap(find.text('Ingreso'));
    await tester.pump();

    expect(find.text('Alimentación'), findsNothing);
    expect(find.text('Sueldo'), findsOneWidget);
  });
}

Wallet buildWallet() {
  return Wallet(
    id: WalletId('wallet-1'),
    name: 'Efectivo',
    initialBalance: const Money(minorUnits: 0, currency: Currency.eur),
  );
}

Category buildCategory({
  String id = 'category-1',
  String name = 'Alimentación',
  CategoryApplicability applicability = CategoryApplicability.both,
}) {
  return Category(
    id: CategoryId(id),
    name: name,
    color: ArgbColor(0xFFF28C28),
    applicability: applicability,
  );
}

final class FakeTransactionRepository implements TransactionRepository {
  Transaction? savedTransaction;

  @override
  Future<void> delete(TransactionId id) async {}

  @override
  Future<List<Transaction>> getAll() async => const [];

  @override
  Future<Transaction?> getById(TransactionId id) async => null;

  @override
  Future<void> save(Transaction transaction) async {
    savedTransaction = transaction;
  }
}
