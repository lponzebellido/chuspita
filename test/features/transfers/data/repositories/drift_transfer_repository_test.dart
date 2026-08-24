import 'package:chuspita/core/currency/currency.dart';
import 'package:chuspita/core/database/app_database.dart';
import 'package:chuspita/core/date/local_date.dart';
import 'package:chuspita/core/date/local_time.dart';
import 'package:chuspita/core/money/money.dart';
import 'package:chuspita/features/transfers/data/repositories/drift_transfer_repository.dart';
import 'package:chuspita/features/transfers/domain/transfer.dart';
import 'package:chuspita/features/transfers/domain/transfer_id.dart';
import 'package:chuspita/features/wallets/data/repositories/drift_wallet_repository.dart';
import 'package:chuspita/features/wallets/domain/wallet.dart';
import 'package:chuspita/features/wallets/domain/wallet_id.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DriftTransferRepository', () {
    late AppDatabase database;
    late DriftTransferRepository repository;
    late int currentTime;

    setUp(() async {
      currentTime = 1000;
      database = AppDatabase(NativeDatabase.memory());
      final walletRepository = DriftWalletRepository(
        database,
        nowMillis: () => currentTime,
      );

      await walletRepository.save(
        buildWallet(id: 'source-wallet', name: 'Euros', currency: Currency.eur),
      );
      await walletRepository.save(
        buildWallet(
          id: 'destination-wallet',
          name: 'Dollars',
          currency: Currency.usd,
        ),
      );

      repository = DriftTransferRepository(
        database,
        nowMillis: () => currentTime,
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('saves and restores a cross-currency transfer', () async {
      final transfer = buildTransfer();

      await repository.save(transfer);
      final restored = await repository.getById(transfer.id);

      expect(restored, isNotNull);
      expect(restored!.sourceWalletId, transfer.sourceWalletId);
      expect(restored.destinationWalletId, transfer.destinationWalletId);
      expect(restored.sourceAmount, transfer.sourceAmount);
      expect(restored.destinationAmount, transfer.destinationAmount);
      expect(restored.occurredOn, transfer.occurredOn);
      expect(restored.occurredAt, transfer.occurredAt);
      expect(restored.note, 'Currency exchange');
      expect(restored.isCurrencyExchange, isTrue);
    });

    test('updates a transfer and its modification timestamp', () async {
      final transfer = buildTransfer();
      await repository.save(transfer);

      currentTime = 2000;
      final updated = buildTransfer(
        sourceAmountMinor: 12000,
        destinationAmountMinor: 13000,
        note: null,
      );
      await repository.save(updated);

      final query = database.select(database.transfers)
        ..where((table) => table.id.equals(transfer.id.value));
      final row = await query.getSingle();
      final restored = await repository.getById(transfer.id);

      expect(row.createdAtMillis, 1000);
      expect(row.updatedAtMillis, 2000);
      expect(restored!.sourceAmount.minorUnits, 12000);
      expect(restored.destinationAmount.minorUnits, 13000);
      expect(restored.note, isNull);
    });

    test('returns all transfers', () async {
      await repository.save(buildTransfer(id: 'transfer-1'));
      await repository.save(buildTransfer(id: 'transfer-2'));

      final transfers = await repository.getAll();

      expect(transfers.map((transfer) => transfer.id).toSet(), {
        TransferId('transfer-1'),
        TransferId('transfer-2'),
      });
    });

    test('rejects an amount currency that differs from its wallet', () async {
      final transfer = buildTransfer(sourceCurrency: Currency.pln);

      expect(() => repository.save(transfer), throwsA(isA<StateError>()));
    });

    test('deletes a transfer', () async {
      final transfer = buildTransfer();
      await repository.save(transfer);

      await repository.delete(transfer.id);

      expect(await repository.getById(transfer.id), isNull);
    });
  });
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

Transfer buildTransfer({
  String id = 'transfer-1',
  int sourceAmountMinor = 10000,
  int destinationAmountMinor = 11000,
  Currency sourceCurrency = Currency.eur,
  String? note = 'Currency exchange',
}) {
  return Transfer(
    id: TransferId(id),
    sourceWalletId: WalletId('source-wallet'),
    destinationWalletId: WalletId('destination-wallet'),
    sourceAmount: Money(
      minorUnits: sourceAmountMinor,
      currency: sourceCurrency,
    ),
    destinationAmount: Money(
      minorUnits: destinationAmountMinor,
      currency: Currency.usd,
    ),
    occurredOn: LocalDate(year: 2026, month: 8, day: 23),
    occurredAt: LocalTime(hour: 18, minute: 20),
    note: note,
  );
}
