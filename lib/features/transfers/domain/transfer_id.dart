final class TransferId {
  factory TransferId(String value) {
    final normalizedValue = value.trim();

    if (normalizedValue.isEmpty) {
      throw ArgumentError.value(value, 'value', 'Transfer id cannot be empty');
    }

    return TransferId._(normalizedValue);
  }

  const TransferId._(this.value);

  final String value;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is TransferId && value == other.value;
  }

  @override
  int get hashCode => value.hashCode;
}
