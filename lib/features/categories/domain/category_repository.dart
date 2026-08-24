import 'package:chuspita/features/categories/domain/category.dart';
import 'package:chuspita/features/categories/domain/category_id.dart';

abstract interface class CategoryRepository {
  Future<List<Category>> getAll();

  Future<Category?> getById(CategoryId id);

  Future<void> save(Category category);
}
