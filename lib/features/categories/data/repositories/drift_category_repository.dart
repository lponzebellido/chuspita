import 'package:chuspita/core/database/app_database.dart';
import 'package:chuspita/features/categories/data/mappers/category_mapper.dart';
import 'package:chuspita/features/categories/domain/category.dart';
import 'package:chuspita/features/categories/domain/category_id.dart';
import 'package:chuspita/features/categories/domain/category_repository.dart';
import 'package:drift/drift.dart';

final class DriftCategoryRepository implements CategoryRepository {
  DriftCategoryRepository(this._database, {int Function()? nowMillis})
    : _nowMillis = nowMillis ?? _currentTimeMillis;

  final AppDatabase _database;
  final int Function() _nowMillis;

  static int _currentTimeMillis() {
    return DateTime.now().millisecondsSinceEpoch;
  }

  @override
  Future<List<Category>> getAll() async {
    final rows = await _database.select(_database.categories).get();

    return rows.map((row) => row.toDomain()).toList(growable: false);
  }

  @override
  Future<Category?> getById(CategoryId id) async {
    final query = _database.select(_database.categories)
      ..where((table) => table.id.equals(id.value));

    final row = await query.getSingleOrNull();

    return row?.toDomain();
  }

  @override
  Future<void> save(Category category) async {
    final query = _database.select(_database.categories)
      ..where((table) => table.id.equals(category.id.value));

    final existingRow = await query.getSingleOrNull();
    final now = _nowMillis();

    if (existingRow == null) {
      await _database
          .into(_database.categories)
          .insert(
            CategoriesCompanion.insert(
              id: category.id.value,
              name: category.name,
              colorArgb: category.color.value,
              isArchived: Value(category.isArchived),
              createdAtMillis: now,
              updatedAtMillis: now,
            ),
          );

      return;
    }

    final updatedAtMillis = now < existingRow.createdAtMillis
        ? existingRow.createdAtMillis
        : now;

    await (_database.update(
      _database.categories,
    )..where((table) => table.id.equals(category.id.value))).write(
      CategoriesCompanion(
        name: Value(category.name),
        colorArgb: Value(category.color.value),
        isArchived: Value(category.isArchived),
        updatedAtMillis: Value(updatedAtMillis),
      ),
    );
  }
}
