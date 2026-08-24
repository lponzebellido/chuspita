import 'package:chuspita/core/color/argb_color.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ArgbColor', () {
    test('stores a valid 32-bit ARGB value', () {
      final color = ArgbColor(0xFF3366CC);

      expect(color.value, 0xFF3366CC);
    });

    test('rejects values outside the 32-bit ARGB range', () {
      expect(() => ArgbColor(-1), throwsArgumentError);
      expect(() => ArgbColor(0x100000000), throwsArgumentError);
    });

    test('uses value equality', () {
      final first = ArgbColor(0xFF3366CC);
      final second = ArgbColor(0xFF3366CC);

      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });
  });
}
