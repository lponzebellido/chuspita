import 'package:chuspita/core/date/local_date.dart';
import 'package:chuspita/core/date/local_time.dart';
import 'package:chuspita/core/money/money.dart';
import 'package:chuspita/features/transfers/domain/transfer.dart';
import 'package:chuspita/features/transfers/domain/transfer_repository.dart';
import 'package:chuspita/features/wallets/domain/wallet_id.dart';

final class UpdateTransfer {
  const UpdateTransfer({required this.transferRepository});

  final TransferRepository transferRepository;

  Future<Transfer> call({
    required Transfer transfer,
    required WalletId sourceWalletId,
    required WalletId destinationWalletId,
    required Money sourceAmount,
    required Money destinationAmount,
    required LocalDate occurredOn,
    LocalTime? occurredAt,
    String? note,
  }) async {
    final updatedTransfer = transfer.updateDetails(
      sourceWalletId: sourceWalletId,
      destinationWalletId: destinationWalletId,
      sourceAmount: sourceAmount,
      destinationAmount: destinationAmount,
      occurredOn: occurredOn,
      occurredAt: occurredAt,
      note: note,
    );

    await transferRepository.save(updatedTransfer);

    return updatedTransfer;
  }
}
