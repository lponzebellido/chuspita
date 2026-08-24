import 'package:chuspita/core/color/argb_color.dart';
import 'package:chuspita/features/categories/domain/category.dart';
import 'package:chuspita/features/categories/domain/category_id.dart';
import 'package:chuspita/features/categories/domain/category_repository.dart';

final class CreateCategory {
  const CreateCategory({
    required this.categoryRepository,
    required this.idGenerator,
  });

  final CategoryRepository categoryRepository;
  final String Function() idGenerator;

  Future<Category> call({
    required String name,
    required ArgbColor color,
  }) async {
    final category = Category(
      id: CategoryId(idGenerator()),
      name: name,
      color: color,
    );

    await categoryRepository.save(category);

    return category;
  }
}
