import 'package:chuspita/core/color/argb_color.dart';
import 'package:chuspita/features/categories/application/update_category.dart';
import 'package:chuspita/features/categories/domain/category.dart';
import 'package:chuspita/features/categories/domain/category_id.dart';
import 'package:chuspita/features/categories/domain/category_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UpdateCategory', () {
    test('updates and saves category details', () async {
      final repository = FakeCategoryRepository();
      final updateCategory = UpdateCategory(categoryRepository: repository);
      final category = buildCategory();

      final updated = await updateCategory.details(
        category: category,
        name: 'Transport',
        color: ArgbColor(0xFF2F80ED),
      );

      expect(updated.name, 'Transport');
      expect(updated.color, ArgbColor(0xFF2F80ED));
      expect(repository.savedCategory, updated);
    });

    test('archives and restores a category', () async {
      final repository = FakeCategoryRepository();
      final updateCategory = UpdateCategory(categoryRepository: repository);
      final category = buildCategory();

      final archived = await updateCategory.archive(category);
      final restored = await updateCategory.restore(archived);

      expect(archived.isArchived, isTrue);
      expect(restored.isArchived, isFalse);
      expect(repository.savedCategory, restored);
    });
  });
}

Category buildCategory() {
  return Category(
    id: CategoryId('category-1'),
    name: 'Food',
    color: ArgbColor(0xFFF28C28),
  );
}

final class FakeCategoryRepository implements CategoryRepository {
  Category? savedCategory;

  @override
  Future<List<Category>> getAll() async => const [];

  @override
  Future<Category?> getById(CategoryId id) async => null;

  @override
  Future<void> save(Category category) async {
    savedCategory = category;
  }
}
