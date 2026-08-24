import 'package:chuspita/features/categories/domain/category_id.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CategoryId', () {
    test('normalizes its value', () {
      final id = CategoryId(' category-1 ');

      expect(id.value, 'category-1');
    });

    test('rejects an empty value', () {
      expect(() => CategoryId('   '), throwsArgumentError);
    });

    test('uses value equality', () {
      final first = CategoryId('category-1');
      final second = CategoryId('category-1');

      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });
  });
}
