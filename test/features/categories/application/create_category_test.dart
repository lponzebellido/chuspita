import 'package:chuspita/core/color/argb_color.dart';
import 'package:chuspita/features/categories/application/create_category.dart';
import 'package:chuspita/features/categories/domain/category.dart';
import 'package:chuspita/features/categories/domain/category_applicability.dart';
import 'package:chuspita/features/categories/domain/category_id.dart';
import 'package:chuspita/features/categories/domain/category_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('creates and saves a category with a generated id', () async {
    final repository = FakeCategoryRepository();
    final createCategory = CreateCategory(
      categoryRepository: repository,
      idGenerator: () => 'category-1',
    );

    final category = await createCategory(
      name: ' Food ',
      color: ArgbColor(0xFFF28C28),
      applicability: CategoryApplicability.expense,
    );

    expect(category.id, CategoryId('category-1'));
    expect(category.name, 'Food');
    expect(category.color, ArgbColor(0xFFF28C28));
    expect(category.applicability, CategoryApplicability.expense);
    expect(repository.savedCategory, category);
  });
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
