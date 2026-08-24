import 'package:chuspita/core/database/app_database.dart';
import 'package:chuspita/features/wallets/data/mappers/wallet_mapper.dart';
import 'package:chuspita/features/wallets/domain/wallet.dart';
import 'package:chuspita/features/wallets/domain/wallet_id.dart';
import 'package:chuspita/features/wallets/domain/wallet_repository.dart';
import 'package:drift/drift.dart';

final class DriftWalletRepository implements WalletRepository {
  DriftWalletRepository(this._database, {int Function()? nowMillis})
    : _nowMillis = nowMillis ?? _currentTimeMillis;

  final AppDatabase _database;
  final int Function() _nowMillis;

  static int _currentTimeMillis() {
    return DateTime.now().millisecondsSinceEpoch;
  }

  @override
  Future<List<Wallet>> getAll() async {
    final rows = await _database.select(_database.wallets).get();

    return rows.map((row) => row.toDomain()).toList(growable: false);
  }

  @override
  Future<Wallet?> getById(WalletId id) async {
    final query = _database.select(_database.wallets)
      ..where((table) => table.id.equals(id.value));

    final row = await query.getSingleOrNull();

    return row?.toDomain();
  }

  @override
  Future<void> save(Wallet wallet) async {
    final query = _database.select(_database.wallets)
      ..where((table) => table.id.equals(wallet.id.value));

    final existingRow = await query.getSingleOrNull();
    final now = _nowMillis();

    if (existingRow == null) {
      await _database
          .into(_database.wallets)
          .insert(
            WalletsCompanion.insert(
              id: wallet.id.value,
              name: wallet.name,
              currencyCode: wallet.currency.code,
              initialBalanceMinor: wallet.initialBalance.minorUnits,
              colorArgb: wallet.color.value,
              isArchived: Value(wallet.isArchived),
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
      _database.wallets,
    )..where((table) => table.id.equals(wallet.id.value))).write(
      WalletsCompanion(
        name: Value(wallet.name),
        currencyCode: Value(wallet.currency.code),
        initialBalanceMinor: Value(wallet.initialBalance.minorUnits),
        colorArgb: Value(wallet.color.value),
        isArchived: Value(wallet.isArchived),
        updatedAtMillis: Value(updatedAtMillis),
      ),
    );
  }
}
