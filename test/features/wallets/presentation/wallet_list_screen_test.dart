import 'package:chuspita/app/app.dart';
import 'package:chuspita/app/providers.dart';
import 'package:chuspita/core/currency/currency.dart';
import 'package:chuspita/core/money/money.dart';
import 'package:chuspita/features/wallets/application/balance_summary.dart';
import 'package:chuspita/features/wallets/domain/wallet.dart';
import 'package:chuspita/features/wallets/domain/wallet_deletion_not_allowed.dart';
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

  testWidgets('deletes an empty wallet after confirmation', (tester) async {
    final wallet = buildWallet();
    final repository = FakeWalletRepository();

    await pumpApp(tester, wallet: wallet, repository: repository);
    await tester.tap(find.byTooltip('Gestionar monederos'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Eliminar'));
    await tester.pumpAndSettle();

    expect(find.text('Eliminar monedero'), findsOneWidget);
    expect(
      find.text(
        'Esta acción eliminará permanentemente el monedero y su saldo '
        'inicial. No se puede deshacer.',
      ),
      findsOneWidget,
    );

    final confirmationButton = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.widgetWithText(FilledButton, 'Eliminar'),
    );
    await tester.tap(confirmationButton);
    await tester.pumpAndSettle();

    expect(repository.deletedId, wallet.id);
  });

  testWidgets('suggests archiving a wallet that has movements', (tester) async {
    final wallet = buildWallet();
    final repository = FakeWalletRepository(
      deleteError: const WalletDeletionNotAllowed(),
    );

    await pumpApp(tester, wallet: wallet, repository: repository);
    await tester.tap(find.byTooltip('Gestionar monederos'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Eliminar'));
    await tester.pumpAndSettle();
    final confirmationButton = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.widgetWithText(FilledButton, 'Eliminar'),
    );
    await tester.tap(confirmationButton);
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Este monedero tiene movimientos financieros. Archívalo para '
        'conservar su historial.',
      ),
      findsOneWidget,
    );
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
        transactionsProvider.overrideWithValue(const AsyncData([])),
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
  FakeWalletRepository({this.deleteError});

  final Object? deleteError;
  Wallet? savedWallet;
  WalletId? deletedId;

  @override
  Future<void> delete(WalletId id) async {
    if (deleteError case final error?) {
      throw error;
    }

    deletedId = id;
  }

  @override
  Future<List<Wallet>> getAll() async => const [];

  @override
  Future<Wallet?> getById(WalletId id) async => null;

  @override
  Future<void> save(Wallet wallet) async {
    savedWallet = wallet;
  }
}
