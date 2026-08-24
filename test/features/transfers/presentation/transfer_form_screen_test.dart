import 'package:chuspita/app/app.dart';
import 'package:chuspita/app/providers.dart';
import 'package:chuspita/core/currency/currency.dart';
import 'package:chuspita/core/date/local_date.dart';
import 'package:chuspita/core/money/money.dart';
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
  testWidgets('creates a cross-currency transfer from home', (tester) async {
    final eurWallet = buildWallet(
      id: 'wallet-eur',
      name: 'Cuenta EUR',
      currency: Currency.eur,
    );
    final penWallet = buildWallet(
      id: 'wallet-pen',
      name: 'Cuenta PEN',
      currency: Currency.pen,
    );
    final repository = FakeTransferRepository();

    await pumpTransferApp(tester, [eurWallet, penWallet], repository);

    await tester.tap(
      find.widgetWithText(FilledButton, 'Transferir entre monederos'),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nueva transferencia'), findsOneWidget);
    expect(find.text('Cantidad enviada'), findsOneWidget);
    expect(find.text('Factor de conversión'), findsOneWidget);
    expect(
      find.text(
        'Este factor es aproximado y puede estar desactualizado. Verifica que sea correcto antes de guardar.',
      ),
      findsOneWidget,
    );

    await tester.enterText(
      find.byKey(const ValueKey('transfer-source-amount')),
      '10,00',
    );
    await tester.enterText(
      find.byKey(const ValueKey('transfer-exchange-rate')),
      '4',
    );
    await tester.pump();
    await tester.scrollUntilVisible(
      find.text('Cantidad calculada'),
      200,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('40,00 PEN'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('transfer-note')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.enterText(
      find.byKey(const ValueKey('transfer-note')),
      'Ahorros',
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Guardar'));
    await tester.pumpAndSettle();

    expect(repository.savedTransfer, isNotNull);
    expect(repository.savedTransfer!.id, TransferId('generated-transfer-id'));
    expect(repository.savedTransfer!.sourceWalletId, eurWallet.id);
    expect(repository.savedTransfer!.destinationWalletId, penWallet.id);
    expect(
      repository.savedTransfer!.sourceAmount,
      const Money(minorUnits: 1000, currency: Currency.eur),
    );
    expect(
      repository.savedTransfer!.destinationAmount,
      const Money(minorUnits: 4000, currency: Currency.pen),
    );
    expect(repository.savedTransfer!.note, 'Ahorros');
  });

  testWidgets('can disable the factor and enter both amounts manually', (
    tester,
  ) async {
    final eurWallet = buildWallet(
      id: 'wallet-eur',
      name: 'Cuenta EUR',
      currency: Currency.eur,
    );
    final penWallet = buildWallet(
      id: 'wallet-pen',
      name: 'Cuenta PEN',
      currency: Currency.pen,
    );

    await pumpTransferApp(tester, [
      eurWallet,
      penWallet,
    ], FakeTransferRepository());
    await tester.tap(
      find.widgetWithText(FilledButton, 'Transferir entre monederos'),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Usar factor de conversión'));
    await tester.pump();

    expect(find.text('Factor de conversión'), findsNothing);
    expect(find.text('Cantidad recibida'), findsOneWidget);
  });

  testWidgets('prefills the latest saved factor for the currency pair', (
    tester,
  ) async {
    final eurWallet = buildWallet(
      id: 'wallet-eur',
      name: 'Cuenta EUR',
      currency: Currency.eur,
    );
    final penWallet = buildWallet(
      id: 'wallet-pen',
      name: 'Cuenta PEN',
      currency: Currency.pen,
    );
    final previousTransfer = Transfer(
      id: TransferId('previous-transfer'),
      sourceWalletId: eurWallet.id,
      destinationWalletId: penWallet.id,
      sourceAmount: const Money(minorUnits: 1000, currency: Currency.eur),
      destinationAmount: const Money(minorUnits: 4125, currency: Currency.pen),
      occurredOn: LocalDate(year: 2026, month: 8, day: 23),
    );

    await pumpTransferApp(tester, [
      eurWallet,
      penWallet,
    ], FakeTransferRepository(initialTransfers: [previousTransfer]));
    await tester.tap(
      find.widgetWithText(FilledButton, 'Transferir entre monederos'),
    );
    await tester.pumpAndSettle();

    final factorField = tester.widget<TextFormField>(
      find.byKey(const ValueKey('transfer-exchange-rate')),
    );

    expect(factorField.controller!.text, '4.125');
    expect(
      find.text(
        'Usamos como referencia el último factor registrado para este par de monedas.',
      ),
      findsOneWidget,
    );
    expect(
      find.text('Aún no hay un factor guardado para este par de monedas.'),
      findsNothing,
    );
  });

  testWidgets('requires two active wallets', (tester) async {
    final wallet = buildWallet(
      id: 'wallet-eur',
      name: 'Cuenta EUR',
      currency: Currency.eur,
    );

    await pumpTransferApp(tester, [wallet], FakeTransferRepository());

    await tester.tap(
      find.widgetWithText(FilledButton, 'Transferir entre monederos'),
    );
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Necesitas al menos dos monederos activos para realizar una transferencia.',
      ),
      findsOneWidget,
    );
    expect(find.widgetWithText(FilledButton, 'Guardar'), findsNothing);
  });
}

Future<void> pumpTransferApp(
  WidgetTester tester,
  List<Wallet> wallets,
  FakeTransferRepository repository,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        balanceSummaryProvider.overrideWithValue(
          AsyncData(
            BalanceSummary(
              byWallet: {
                for (final wallet in wallets) wallet.id: wallet.initialBalance,
              },
              byCurrency: {
                for (final wallet in wallets)
                  wallet.currency: wallet.initialBalance,
              },
            ),
          ),
        ),
        walletsProvider.overrideWithValue(AsyncData(wallets)),
        transferRepositoryProvider.overrideWithValue(repository),
        transferIdGeneratorProvider.overrideWithValue(
          () => 'generated-transfer-id',
        ),
      ],
      child: const ChuspitaApp(locale: Locale('es')),
    ),
  );
  await tester.pump();
}

Wallet buildWallet({
  required String id,
  required String name,
  required Currency currency,
}) {
  return Wallet(
    id: WalletId(id),
    name: name,
    initialBalance: Money(minorUnits: 0, currency: currency),
  );
}

final class FakeTransferRepository implements TransferRepository {
  FakeTransferRepository({this.initialTransfers = const []});

  final List<Transfer> initialTransfers;
  Transfer? savedTransfer;

  @override
  Future<void> delete(TransferId id) async {}

  @override
  Future<List<Transfer>> getAll() async => initialTransfers;

  @override
  Future<Transfer?> getById(TransferId id) async => null;

  @override
  Future<void> save(Transfer transfer) async {
    savedTransfer = transfer;
  }
}
