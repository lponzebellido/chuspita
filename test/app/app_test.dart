import 'dart:async';

import 'package:chuspita/app/app.dart';
import 'package:chuspita/app/branding/app_branding.dart';
import 'package:chuspita/app/providers.dart';
import 'package:chuspita/core/color/argb_color.dart';
import 'package:chuspita/core/currency/currency.dart';
import 'package:chuspita/core/date/local_date.dart';
import 'package:chuspita/core/money/money.dart';
import 'package:chuspita/features/categories/domain/category.dart';
import 'package:chuspita/features/categories/domain/category_id.dart';
import 'package:chuspita/features/transactions/domain/transaction.dart';
import 'package:chuspita/features/transactions/domain/transaction_id.dart';
import 'package:chuspita/features/wallets/application/balance_summary.dart';
import 'package:chuspita/features/wallets/domain/wallet_id.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows a loading indicator while balances load', (tester) async {
    final pendingSummary = Completer<BalanceSummary>();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          balanceSummaryProvider.overrideWith((ref) => pendingSummary.future),
          transactionsProvider.overrideWithValue(const AsyncData([])),
        ],
        child: const ChuspitaApp(locale: Locale('es')),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows an empty state when there are no wallets', (tester) async {
    final summary = BalanceSummary(byWallet: const {}, byCurrency: const {});

    await pumpApp(tester, summary);

    expect(find.text('Aún no tienes monederos'), findsOneWidget);
  });

  testWidgets('shows the brand logo in the home app bar', (tester) async {
    final summary = BalanceSummary(byWallet: const {}, byCurrency: const {});

    await pumpApp(tester, summary);

    final logo = tester.widget<Image>(
      find.byKey(const ValueKey('chuspita-logo')),
    );
    expect(logo.image, isA<AssetImage>());
    expect((logo.image as AssetImage).assetName, AppBranding.logoAsset);
  });

  testWidgets('supports English', (tester) async {
    final summary = BalanceSummary(byWallet: const {}, byCurrency: const {});

    await pumpApp(tester, summary, locale: const Locale('en'));

    expect(find.text("You don't have any wallets yet"), findsOneWidget);
  });

  testWidgets('shows balances grouped by currency', (tester) async {
    final summary = BalanceSummary(
      byWallet: {
        WalletId('wallet-eur'): const Money(
          minorUnits: 12530,
          currency: Currency.eur,
        ),
        WalletId('wallet-pen'): const Money(
          minorUnits: 4020,
          currency: Currency.pen,
        ),
      },
      byCurrency: {
        Currency.eur: const Money(minorUnits: 12530, currency: Currency.eur),
        Currency.pen: const Money(minorUnits: 4020, currency: Currency.pen),
      },
    );

    await pumpApp(tester, summary);

    expect(find.text('Balance por moneda'), findsOneWidget);
    expect(find.text('EUR'), findsOneWidget);
    expect(find.text('125,30'), findsOneWidget);
    expect(find.text('PEN'), findsOneWidget);
    expect(find.text('40,20'), findsOneWidget);
  });

  testWidgets('shows the current month income, expenses and net by currency', (
    tester,
  ) async {
    final summary = BalanceSummary(
      byWallet: {
        WalletId('wallet-eur'): const Money(
          minorUnits: 10000,
          currency: Currency.eur,
        ),
      },
      byCurrency: {
        Currency.eur: const Money(minorUnits: 10000, currency: Currency.eur),
      },
    );
    final transactions = [
      buildTransaction(
        id: 'income',
        type: TransactionType.income,
        amountMinor: 10000,
        occurredOn: LocalDate(year: 2026, month: 8, day: 2),
      ),
      buildTransaction(
        id: 'expense',
        type: TransactionType.expense,
        amountMinor: 4120,
        occurredOn: LocalDate(year: 2026, month: 8, day: 20),
      ),
      buildTransaction(
        id: 'previous-month',
        type: TransactionType.expense,
        amountMinor: 5000,
        occurredOn: LocalDate(year: 2026, month: 7, day: 31),
      ),
    ];

    await pumpApp(
      tester,
      summary,
      transactions: transactions,
      currentDate: LocalDate(year: 2026, month: 8, day: 24),
    );
    await tester.scrollUntilVisible(
      find.text('Ingresos'),
      200,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Este mes'), findsOneWidget);
    expect(find.text('Ingresos'), findsOneWidget);
    expect(find.text('100,00 EUR'), findsOneWidget);
    expect(find.text('Gastos'), findsNWidgets(2));
    expect(find.text('41,20 EUR'), findsNWidgets(2));
    expect(find.text('Balance'), findsOneWidget);
    expect(find.text('58,80 EUR'), findsOneWidget);
  });

  testWidgets('shows current month expenses by category', (tester) async {
    final summary = BalanceSummary(
      byWallet: {
        WalletId('wallet-eur'): const Money(
          minorUnits: 10000,
          currency: Currency.eur,
        ),
      },
      byCurrency: {
        Currency.eur: const Money(minorUnits: 10000, currency: Currency.eur),
      },
    );
    final transactions = [
      buildTransaction(
        id: 'food-expense',
        type: TransactionType.expense,
        amountMinor: 3000,
        occurredOn: LocalDate(year: 2026, month: 8, day: 10),
        categoryId: 'food',
      ),
      buildTransaction(
        id: 'transport-expense',
        type: TransactionType.expense,
        amountMinor: 1000,
        occurredOn: LocalDate(year: 2026, month: 8, day: 11),
        categoryId: 'transport',
      ),
      buildTransaction(
        id: 'salary-income',
        type: TransactionType.income,
        amountMinor: 10000,
        occurredOn: LocalDate(year: 2026, month: 8, day: 1),
        categoryId: 'salary',
      ),
    ];

    await pumpApp(
      tester,
      summary,
      transactions: transactions,
      categories: [
        buildCategory('food', 'Alimentación', 0xFFF28C28),
        buildCategory('transport', 'Transporte', 0xFF2F80ED),
        buildCategory('salary', 'Sueldo', 0xFF4E9F3D),
      ],
      currentDate: LocalDate(year: 2026, month: 8, day: 24),
    );
    await tester.drag(find.byType(ListView).first, const Offset(0, -600));
    await tester.pumpAndSettle();

    expect(find.text('Gastos por categoría'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('category-spending-chart-EUR')),
      findsOneWidget,
    );
    expect(find.text('Alimentación'), findsOneWidget);
    expect(find.text('75% · 30,00 EUR'), findsOneWidget);
    expect(find.text('Transporte'), findsOneWidget);
    expect(find.text('25% · 10,00 EUR'), findsOneWidget);
    expect(find.text('Sueldo'), findsNothing);
  });

  testWidgets('shows an error state', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          balanceSummaryProvider.overrideWithValue(
            AsyncError(StateError('Database failed'), StackTrace.empty),
          ),
          transactionsProvider.overrideWithValue(const AsyncData([])),
        ],
        child: const ChuspitaApp(locale: Locale('es')),
      ),
    );
    await tester.pump();

    expect(find.text('No pudimos cargar tus datos.'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
  });
}

Future<void> pumpApp(
  WidgetTester tester,
  BalanceSummary summary, {
  Locale locale = const Locale('es'),
  List<Transaction> transactions = const [],
  List<Category> categories = const [],
  LocalDate? currentDate,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        balanceSummaryProvider.overrideWithValue(AsyncData(summary)),
        transactionsProvider.overrideWithValue(AsyncData(transactions)),
        categoriesProvider.overrideWithValue(AsyncData(categories)),
        if (currentDate != null)
          currentDateProvider.overrideWithValue(currentDate),
      ],
      child: ChuspitaApp(locale: locale),
    ),
  );
  await tester.pump();
}

Transaction buildTransaction({
  required String id,
  required TransactionType type,
  required int amountMinor,
  required LocalDate occurredOn,
  String categoryId = 'category-1',
}) {
  return Transaction(
    id: TransactionId(id),
    type: type,
    amount: Money(minorUnits: amountMinor, currency: Currency.eur),
    walletId: WalletId('wallet-eur'),
    categoryId: CategoryId(categoryId),
    occurredOn: occurredOn,
  );
}

Category buildCategory(String id, String name, int color) {
  return Category(id: CategoryId(id), name: name, color: ArgbColor(color));
}
