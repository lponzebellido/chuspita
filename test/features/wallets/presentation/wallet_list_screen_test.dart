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
  testWidgets('opens wallet management and edits a wallet', (tester) async {
    final wallet = buildWallet();
    final repository = FakeWalletRepository();

    await pumpApp(tester, wallet: wallet, repository: repository);
    await tester.tap(find.byTooltip('Gestionar monederos'));
    await tester.pumpAndSettle();

    expect(find.text('Monederos'), findsOneWidget);
    expect(find.text('Efectivo'), findsOneWidget);

    await tester.tap(find.text('Efectivo'));
    await tester.pumpAndSettle();

    expect(find.text('Editar monedero'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).first, 'Cuenta bancaria');
    await tester.tap(find.widgetWithText(FilledButton, 'Guardar'));
    await tester.pumpAndSettle();

    expect(repository.savedWallet, isNotNull);
    expect(repository.savedWallet!.name, 'Cuenta bancaria');
    expect(repository.savedWallet!.id, wallet.id);
  });

  testWidgets('archives a wallet from its menu', (tester) async {
    final wallet = buildWallet();
    final repository = FakeWalletRepository();

    await pumpApp(tester, wallet: wallet, repository: repository);
    await tester.tap(find.byTooltip('Gestionar monederos'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Archivar'));
    await tester.pump();

    expect(repository.savedWallet, isNotNull);
    expect(repository.savedWallet!.isArchived, isTrue);
  });
}

Future<void> pumpApp(
  WidgetTester tester, {
  required Wallet wallet,
  required FakeWalletRepository repository,
}) async {
  final summary = BalanceSummary(
    byWallet: {wallet.id: wallet.initialBalance},
    byCurrency: {wallet.currency: wallet.initialBalance},
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        balanceSummaryProvider.overrideWithValue(AsyncData(summary)),
        walletsProvider.overrideWithValue(AsyncData([wallet])),
        walletRepositoryProvider.overrideWithValue(repository),
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
    initialBalance: const Money(minorUnits: 1000, currency: Currency.eur),
  );
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
