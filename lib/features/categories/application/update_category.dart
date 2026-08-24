import 'package:chuspita/core/color/argb_color.dart';
import 'package:chuspita/features/categories/domain/category.dart';
import 'package:chuspita/features/categories/domain/category_repository.dart';

final class UpdateCategory {
  const UpdateCategory({required this.categoryRepository});

  final CategoryRepository categoryRepository;

  Future<Category> details({
    required Category category,
    required String name,
    required ArgbColor color,
  }) async {
    final updatedCategory = category.updateDetails(name: name, color: color);
    await categoryRepository.save(updatedCategory);
    return updatedCategory;
  }

  Future<Category> archive(Category category) async {
    final archivedCategory = category.archive();
    await categoryRepository.save(archivedCategory);
    return archivedCategory;
  }

  Future<Category> restore(Category category) async {
    final restoredCategory = category.restore();
    await categoryRepository.save(restoredCategory);
    return restoredCategory;
  }
}
