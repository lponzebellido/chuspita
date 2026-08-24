import 'package:chuspita/app/app.dart';
import 'package:chuspita/app/providers.dart';
import 'package:chuspita/core/currency/currency.dart';
import 'package:chuspita/core/money/money.dart';
import 'package:chuspita/features/wallets/application/balance_summary.dart';
import 'package:chuspita/features/wallets/domain/wallet.dart';
import 'package:chuspita/features/wallets/domain/wallet_id.dart';
import 'package:chuspita/features/wallets/domain/wallet_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('creates a wallet from the empty state', (tester) async {
    final repository = FakeWalletRepository();
    final emptySummary = BalanceSummary(
      byWallet: const {},
      byCurrency: const {},
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          balanceSummaryProvider.overrideWithValue(AsyncData(emptySummary)),
          walletRepositoryProvider.overrideWithValue(repository),
          walletIdGeneratorProvider.overrideWithValue(
            () => 'generated-wallet-id',
          ),
        ],
        child: const ChuspitaApp(locale: Locale('es')),
      ),
    );
    await tester.pump();

    await tester.tap(find.widgetWithText(FilledButton, 'Añadir monedero'));
    await tester.pumpAndSettle();

    expect(find.text('Nuevo monedero'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'Efectivo');
    await tester.enterText(find.byType(TextFormField).at(1), '12,53');
    await tester.tap(find.widgetWithText(FilledButton, 'Guardar'));
    await tester.pumpAndSettle();

    expect(find.text('Nuevo monedero'), findsNothing);
    expect(repository.savedWallet, isNotNull);
    expect(repository.savedWallet!.id, WalletId('generated-wallet-id'));
    expect(repository.savedWallet!.name, 'Efectivo');
    expect(
      repository.savedWallet!.initialBalance,
      const Money(minorUnits: 1253, currency: Currency.eur),
    );
  });
}

final class FakeWalletRepository implements WalletRepository {
  Wallet? savedWallet;

  @override
  Future<List<Wallet>> getAll() async => const [];

  @override
  Future<Wallet?> getById(WalletId id) async => null;

  @override
  Future<void> save(Wallet wallet) async {
    savedWallet = wallet;
  }
}
