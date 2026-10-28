import 'package:chuspita/features/transfers/domain/transfer.dart';
import 'package:chuspita/features/transfers/domain/transfer_repository.dart';

final class DeleteTransfer {
  const DeleteTransfer({required this.transferRepository});

  final TransferRepository transferRepository;

  Future<void> call(Transfer transfer) {
    return transferRepository.delete(transfer.id);
  }
}
