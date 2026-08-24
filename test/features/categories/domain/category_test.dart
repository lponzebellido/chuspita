import 'package:chuspita/core/color/argb_color.dart';
import 'package:chuspita/features/categories/domain/category.dart';
import 'package:chuspita/features/categories/domain/category_id.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Category', () {
    test('creates an active category', () {
      final category = buildCategory();

      expect(category.name, 'Food');
      expect(category.color, ArgbColor(0xFFFF9800));
      expect(category.isArchived, isFalse);
    });

    test('normalizes its name', () {
      final category = buildCategory(name: '  Transport  ');

      expect(category.name, 'Transport');
    });

    test('rejects an empty name', () {
      expect(() => buildCategory(name: '   '), throwsArgumentError);
    });

    test('archives immutably', () {
      final activeCategory = buildCategory();

      final archivedCategory = activeCategory.archive();

      expect(activeCategory.isArchived, isFalse);
      expect(archivedCategory.isArchived, isTrue);
      expect(archivedCategory.id, activeCategory.id);
    });

    test('updates details while preserving identity and state', () {
      final category = buildCategory(isArchived: true);

      final updated = category.updateDetails(
        name: 'Transport',
        color: ArgbColor(0xFF2196F3),
      );

      expect(updated.id, category.id);
      expect(updated.name, 'Transport');
      expect(updated.color, ArgbColor(0xFF2196F3));
      expect(updated.isArchived, isTrue);
    });

    test('restores an archived category', () {
      final archived = buildCategory(isArchived: true);

      final restored = archived.restore();

      expect(restored.isArchived, isFalse);
      expect(restored.id, archived.id);
    });

    test('uses entity equality based on its id', () {
      final id = CategoryId('category-1');
      final first = buildCategory(id: id, name: 'Food');
      final second = buildCategory(id: id, name: 'Transport');

      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });
  });
}

Category buildCategory({
  CategoryId? id,
  String name = 'Food',
  ArgbColor? color,
  bool isArchived = false,
}) {
  return Category(
    id: id ?? CategoryId('category-1'),
    name: name,
    color: color ?? ArgbColor(0xFFFF9800),
    isArchived: isArchived,
  );
}
