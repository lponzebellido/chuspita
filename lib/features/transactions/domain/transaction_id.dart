final class TransactionId {
  factory TransactionId(String value) {
    final normalizedValue = value.trim();

    if (normalizedValue.isEmpty) {
      throw ArgumentError.value(
        value,
        'value',
        'Transaction id cannot be empty',
      );
    }

    return TransactionId._(normalizedValue);
  }

  const TransactionId._(this.value);

  final String value;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is TransactionId && value == other.value;
  }

  @override
  int get hashCode => value.hashCode;
}
