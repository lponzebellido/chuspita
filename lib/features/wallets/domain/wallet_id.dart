final class WalletId {
  factory WalletId(String value) {
    final normalizedValue = value.trim();

    if (normalizedValue.isEmpty) {
      throw ArgumentError.value(value, 'value', 'Wallet id cannot be empty');
    }

    return WalletId._(normalizedValue);
  }

  const WalletId._(this.value);

  final String value;

  @override
  bool operator ==(Object other) {
    return identical(this, other) || other is WalletId && value == other.value;
  }

  @override
  int get hashCode => value.hashCode;
}
