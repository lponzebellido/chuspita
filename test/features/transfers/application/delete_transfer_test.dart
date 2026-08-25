import 'package:chuspita/core/currency/currency.dart';
import 'package:chuspita/core/date/local_date.dart';
import 'package:chuspita/core/money/money.dart';
import 'package:chuspita/features/transfers/application/delete_transfer.dart';
import 'package:chuspita/features/transfers/domain/transfer.dart';
import 'package:chuspita/features/transfers/domain/transfer_id.dart';
import 'package:chuspita/features/transfers/domain/transfer_repository.dart';
import 'package:chuspita/features/wallets/domain/wallet_id.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('deletes the requested transfer', () async {
    final repository = FakeTransferRepository();
    final deleteTransfer = DeleteTransfer(transferRepository: repository);
    final transfer = Transfer(
      id: TransferId('transfer-1'),
      sourceWalletId: WalletId('wallet-eur'),
      destinationWalletId: WalletId('wallet-pen'),
      sourceAmount: const Money(minorUnits: 1000, currency: Currency.eur),
      destinationAmount: const Money(minorUnits: 4000, currency: Currency.pen),
      occurredOn: LocalDate(year: 2026, month: 8, day: 24),
    );

    await deleteTransfer(transfer);

    expect(repository.deletedId, transfer.id);
  });
}

final class FakeTransferRepository implements TransferRepository {
  TransferId? deletedId;

  @override
  Future<void> delete(TransferId id) async {
    deletedId = id;
  }

  @override
  Future<List<Transfer>> getAll() async => const [];

  @override
  Future<Transfer?> getById(TransferId id) async => null;

  @override
  Future<void> save(Transfer transfer) async {}
}
