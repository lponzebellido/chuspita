import 'package:chuspita/core/date/local_date.dart';
import 'package:chuspita/core/money/money.dart';
import 'package:chuspita/features/transfers/domain/transfer.dart';
import 'package:chuspita/features/transfers/domain/transfer_id.dart';
import 'package:chuspita/features/transfers/domain/transfer_repository.dart';
import 'package:chuspita/features/wallets/domain/wallet_id.dart';

final class CreateTransfer {
  const CreateTransfer({
    required this.transferRepository,
    required this.idGenerator,
  });

  final TransferRepository transferRepository;
  final String Function() idGenerator;

  Future<Transfer> call({
    required WalletId sourceWalletId,
    required WalletId destinationWalletId,
    required Money sourceAmount,
    required Money destinationAmount,
    required LocalDate occurredOn,
    String? note,
  }) async {
    final transfer = Transfer(
      id: TransferId(idGenerator()),
      sourceWalletId: sourceWalletId,
      destinationWalletId: destinationWalletId,
      sourceAmount: sourceAmount,
      destinationAmount: destinationAmount,
      occurredOn: occurredOn,
      note: note,
    );

    await transferRepository.save(transfer);

    return transfer;
  }
}
