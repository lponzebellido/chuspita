import 'package:chuspita/core/currency/currency.dart';
import 'package:chuspita/core/database/app_database.dart';
import 'package:chuspita/features/transfers/data/mappers/transfer_mapper.dart';
import 'package:chuspita/features/transfers/domain/transfer.dart';
import 'package:chuspita/features/transfers/domain/transfer_id.dart';
import 'package:chuspita/features/transfers/domain/transfer_repository.dart';
import 'package:chuspita/features/wallets/domain/wallet_id.dart';
import 'package:drift/drift.dart';

final class DriftTransferRepository implements TransferRepository {
  DriftTransferRepository(this._database, {int Function()? nowMillis})
    : _nowMillis = nowMillis ?? _currentTimeMillis;

  final AppDatabase _database;
  final int Function() _nowMillis;

  static int _currentTimeMillis() {
    return DateTime.now().millisecondsSinceEpoch;
  }

  @override
  Future<List<Transfer>> getAll() async {
    final rows = await _database.select(_database.transfers).get();

    if (rows.isEmpty) {
      return const [];
    }

    final walletRows = await _database.select(_database.wallets).get();
    final currenciesByWalletId = {
      for (final wallet in walletRows)
        wallet.id: Currency.fromCode(wallet.currencyCode),
    };

    return rows
        .map((row) {
          final sourceCurrency = currenciesByWalletId[row.sourceWalletId];
          final destinationCurrency =
              currenciesByWalletId[row.destinationWalletId];

          if (sourceCurrency == null || destinationCurrency == null) {
            throw StateError('Transfer ${row.id} references a missing wallet');
          }

          return row.toDomain(
            sourceCurrency: sourceCurrency,
            destinationCurrency: destinationCurrency,
          );
        })
        .toList(growable: false);
  }

  @override
  Future<Transfer?> getById(TransferId id) async {
    final query = _database.select(_database.transfers)
      ..where((table) => table.id.equals(id.value));
    final row = await query.getSingleOrNull();

    if (row == null) {
      return null;
    }

    final sourceWallet = await _requireWallet(WalletId(row.sourceWalletId));
    final destinationWallet = await _requireWallet(
      WalletId(row.destinationWalletId),
    );

    return row.toDomain(
      sourceCurrency: Currency.fromCode(sourceWallet.currencyCode),
      destinationCurrency: Currency.fromCode(destinationWallet.currencyCode),
    );
  }

  @override
  Future<void> save(Transfer transfer) async {
    await _database.transaction(() async {
      final sourceWallet = await _requireWallet(transfer.sourceWalletId);
      final destinationWallet = await _requireWallet(
        transfer.destinationWalletId,
      );
      final sourceCurrency = Currency.fromCode(sourceWallet.currencyCode);
      final destinationCurrency = Currency.fromCode(
        destinationWallet.currencyCode,
      );

      if (transfer.sourceAmount.currency != sourceCurrency) {
        throw StateError(
          'Source amount currency ${transfer.sourceAmount.currency.code} does '
          'not match source wallet currency ${sourceCurrency.code}',
        );
      }

      if (transfer.destinationAmount.currency != destinationCurrency) {
        throw StateError(
          'Destination amount currency '
          '${transfer.destinationAmount.currency.code} does not match '
          'destination wallet currency ${destinationCurrency.code}',
        );
      }

      final query = _database.select(_database.transfers)
        ..where((table) => table.id.equals(transfer.id.value));
      final existingRow = await query.getSingleOrNull();
      final now = _nowMillis();

      if (existingRow == null) {
        await _database
            .into(_database.transfers)
            .insert(
              TransfersCompanion.insert(
                id: transfer.id.value,
                sourceWalletId: transfer.sourceWalletId.value,
                destinationWalletId: transfer.destinationWalletId.value,
                sourceAmountMinor: transfer.sourceAmount.minorUnits,
                destinationAmountMinor: transfer.destinationAmount.minorUnits,
                occurredOn: transfer.occurredOn.toString(),
                note: Value(transfer.note),
                createdAtMillis: now,
                updatedAtMillis: now,
              ),
            );

        return;
      }

      final updatedAtMillis = now < existingRow.createdAtMillis
          ? existingRow.createdAtMillis
          : now;

      await (_database.update(
        _database.transfers,
      )..where((table) => table.id.equals(transfer.id.value))).write(
        TransfersCompanion(
          sourceWalletId: Value(transfer.sourceWalletId.value),
          destinationWalletId: Value(transfer.destinationWalletId.value),
          sourceAmountMinor: Value(transfer.sourceAmount.minorUnits),
          destinationAmountMinor: Value(transfer.destinationAmount.minorUnits),
          occurredOn: Value(transfer.occurredOn.toString()),
          note: Value(transfer.note),
          updatedAtMillis: Value(updatedAtMillis),
        ),
      );
    });
  }

  @override
  Future<void> delete(TransferId id) async {
    await (_database.delete(
      _database.transfers,
    )..where((table) => table.id.equals(id.value))).go();
  }

  Future<WalletRow> _requireWallet(WalletId id) async {
    final query = _database.select(_database.wallets)
      ..where((table) => table.id.equals(id.value));
    final wallet = await query.getSingleOrNull();

    if (wallet == null) {
      throw StateError('Wallet ${id.value} does not exist');
    }

    return wallet;
  }
}
