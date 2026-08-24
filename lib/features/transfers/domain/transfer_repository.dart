import 'package:chuspita/features/transfers/domain/transfer.dart';
import 'package:chuspita/features/transfers/domain/transfer_id.dart';

abstract interface class TransferRepository {
  Future<List<Transfer>> getAll();

  Future<Transfer?> getById(TransferId id);

  Future<void> save(Transfer transfer);

  Future<void> delete(TransferId id);
}
