final class ArgbColor {
  factory ArgbColor(int value) {
    if (value < 0 || value > 0xFFFFFFFF) {
      throw ArgumentError.value(
        value,
        'value',
        'Color must be a 32-bit ARGB value',
      );
    }

    return ArgbColor._(value);
  }

  const ArgbColor._(this.value);

  final int value;

  @override
  bool operator ==(Object other) {
    return identical(this, other) || other is ArgbColor && value == other.value;
  }

  @override
  int get hashCode => value.hashCode;
}
