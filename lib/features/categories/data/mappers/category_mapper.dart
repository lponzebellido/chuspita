import 'package:chuspita/core/color/argb_color.dart';
import 'package:chuspita/core/database/app_database.dart';
import 'package:chuspita/features/categories/domain/category.dart';
import 'package:chuspita/features/categories/domain/category_id.dart';

extension CategoryRowMapper on CategoryRow {
  Category toDomain() {
    return Category(
      id: CategoryId(id),
      name: name,
      color: ArgbColor(colorArgb),
      isArchived: isArchived,
    );
  }
}
