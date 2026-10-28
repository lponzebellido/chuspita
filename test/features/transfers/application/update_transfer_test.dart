import 'package:chuspita/core/currency/currency.dart';
import 'package:chuspita/core/date/local_date.dart';
import 'package:chuspita/core/date/local_time.dart';
import 'package:chuspita/core/money/money.dart';
import 'package:chuspita/features/transfers/application/update_transfer.dart';
import 'package:chuspita/features/transfers/domain/transfer.dart';
import 'package:chuspita/features/transfers/domain/transfer_id.dart';
import 'package:chuspita/features/transfers/domain/transfer_repository.dart';
import 'package:chuspita/features/wallets/domain/wallet_id.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('updates and saves a transfer while preserving its identity', () async {
    final repository = FakeTransferRepository();
    final transfer = _buildTransfer();
    final updateTransfer = UpdateTransfer(transferRepository: repository);

    final updated = await updateTransfer(
      transfer: transfer,
      sourceWalletId: transfer.sourceWalletId,
      destinationWalletId: transfer.destinationWalletId,
      sourceAmount: const Money(minorUnits: 2000, currency: Currency.eur),
      destinationAmount: const Money(minorUnits: 7800, currency: Currency.pen),
      occurredOn: LocalDate(year: 2026, month: 8, day: 25),
      occurredAt: LocalTime(hour: 14, minute: 30),
      note: 'Corrected exchange',
    );

    expect(updated.id, transfer.id);
    expect(updated.sourceAmount.minorUnits, 2000);
    expect(updated.destinationAmount.minorUnits, 7800);
    expect(updated.occurredOn, LocalDate(year: 2026, month: 8, day: 25));
    expect(updated.occurredAt, LocalTime(hour: 14, minute: 30));
    expect(updated.note, 'Corrected exchange');
    expect(repository.savedTransfer, updated);
  });
}

Transfer _buildTransfer() {
  return Transfer(
    id: TransferId('transfer-1'),
    sourceWalletId: WalletId('wallet-eur'),
    destinationWalletId: WalletId('wallet-pen'),
    sourceAmount: const Money(minorUnits: 1000, currency: Currency.eur),
    destinationAmount: const Money(minorUnits: 4000, currency: Currency.pen),
    occurredOn: LocalDate(year: 2026, month: 8, day: 24),
  );
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
