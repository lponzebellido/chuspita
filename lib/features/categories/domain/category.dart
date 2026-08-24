import 'package:chuspita/core/color/argb_color.dart';
import 'package:chuspita/features/categories/domain/category_id.dart';

final class Category {
  factory Category({
    required CategoryId id,
    required String name,
    required ArgbColor color,
    bool isArchived = false,
  }) {
    final normalizedName = name.trim();

    if (normalizedName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Category name cannot be empty');
    }

    return Category._(
      id: id,
      name: normalizedName,
      color: color,
      isArchived: isArchived,
    );
  }

  const Category._({
    required this.id,
    required this.name,
    required this.color,
    required this.isArchived,
  });

  final CategoryId id;
  final String name;
  final ArgbColor color;
  final bool isArchived;

  Category archive() {
    if (isArchived) {
      return this;
    }

    return Category._(id: id, name: name, color: color, isArchived: true);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || other is Category && id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}
