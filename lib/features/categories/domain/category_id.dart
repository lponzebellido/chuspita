final class CategoryId {
  factory CategoryId(String value) {
    final normalizedValue = value.trim();

    if (normalizedValue.isEmpty) {
      throw ArgumentError.value(value, 'value', 'Category id cannot be empty');
    }

    return CategoryId._(normalizedValue);
  }

  const CategoryId._(this.value);

  final String value;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is CategoryId && value == other.value;
  }

  @override
  int get hashCode => value.hashCode;
}
