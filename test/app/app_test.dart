import 'dart:async';

import 'package:chuspita/app/app.dart';
import 'package:chuspita/app/providers.dart';
import 'package:chuspita/core/currency/currency.dart';
import 'package:chuspita/core/money/money.dart';
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

  testWidgets('shows an error state', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          balanceSummaryProvider.overrideWithValue(
            AsyncError(StateError('Database failed'), StackTrace.empty),
          ),
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
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [balanceSummaryProvider.overrideWithValue(AsyncData(summary))],
      child: ChuspitaApp(locale: locale),
    ),
  );
  await tester.pump();
}
