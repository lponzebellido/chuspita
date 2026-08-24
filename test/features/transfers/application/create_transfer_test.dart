import 'package:chuspita/core/currency/currency.dart';
import 'package:chuspita/core/date/local_date.dart';
import 'package:chuspita/core/money/money.dart';
import 'package:chuspita/features/transfers/application/create_transfer.dart';
import 'package:chuspita/features/transfers/domain/transfer.dart';
import 'package:chuspita/features/transfers/domain/transfer_id.dart';
import 'package:chuspita/features/transfers/domain/transfer_repository.dart';
import 'package:chuspita/features/wallets/domain/wallet_id.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('creates and saves a transfer with a generated id', () async {
    final repository = FakeTransferRepository();
    final createTransfer = CreateTransfer(
      transferRepository: repository,
      idGenerator: () => 'transfer-1',
    );

    final transfer = await createTransfer(
      sourceWalletId: WalletId('wallet-eur'),
      destinationWalletId: WalletId('wallet-pen'),
      sourceAmount: const Money(minorUnits: 1000, currency: Currency.eur),
      destinationAmount: const Money(minorUnits: 4000, currency: Currency.pen),
      occurredOn: LocalDate(year: 2026, month: 8, day: 24),
      note: 'Exchange',
    );

    expect(transfer.id, TransferId('transfer-1'));
    expect(transfer.sourceWalletId, WalletId('wallet-eur'));
    expect(transfer.destinationWalletId, WalletId('wallet-pen'));
    expect(repository.savedTransfer, transfer);
  });
}

final class FakeTransferRepository implements TransferRepository {
  Transfer? savedTransfer;

  @override
  Future<void> delete(TransferId id) async {}

  @override
  Future<List<Transfer>> getAll() async => const [];

  @override
  Future<Transfer?> getById(TransferId id) async => null;

  @override
  Future<void> save(Transfer transfer) async {
    savedTransfer = transfer;
  }
}
