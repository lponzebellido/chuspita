import 'package:chuspita/core/currency/currency.dart';
import 'package:chuspita/core/money/money.dart';
import 'package:chuspita/features/wallets/domain/wallet_id.dart';

final class Wallet {
  factory Wallet({
    required WalletId id,
    required String name,
    required Money initialBalance,
    bool isArchived = false,
  }) {
    final normalizedName = name.trim();

    if (normalizedName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Wallet name cannot be empty');
    }

    return Wallet._(
      id: id,
      name: normalizedName,
      initialBalance: initialBalance,
      isArchived: isArchived,
    );
  }

  const Wallet._({
    required this.id,
    required this.name,
    required this.initialBalance,
    required this.isArchived,
  });

  final WalletId id;
  final String name;
  final Money initialBalance;
  final bool isArchived;

  Currency get currency => initialBalance.currency;

  Wallet updateDetails({required String name, required Money initialBalance}) {
    return Wallet(
      id: id,
      name: name,
      initialBalance: initialBalance,
      isArchived: isArchived,
    );
  }

  Wallet archive() {
    if (isArchived) {
      return this;
    }

    return Wallet._(
      id: id,
      name: name,
      initialBalance: initialBalance,
      isArchived: true,
    );
  }

  Wallet restore() {
    if (!isArchived) {
      return this;
    }

    return Wallet(id: id, name: name, initialBalance: initialBalance);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || other is Wallet && id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}
