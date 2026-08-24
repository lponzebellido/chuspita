import 'package:chuspita/core/color/argb_color.dart';
import 'package:chuspita/core/database/app_database.dart';
import 'package:chuspita/features/categories/data/repositories/drift_category_repository.dart';
import 'package:chuspita/features/categories/domain/category.dart';
import 'package:chuspita/features/categories/domain/category_id.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DriftCategoryRepository', () {
    late AppDatabase database;
    late DriftCategoryRepository repository;
    late int currentTime;

    setUp(() {
      currentTime = 1000;
      database = AppDatabase(NativeDatabase.memory());
      repository = DriftCategoryRepository(
        database,
        nowMillis: () => currentTime,
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('saves and restores a category', () async {
      final category = buildCategory();

      await repository.save(category);
      final restored = await repository.getById(category.id);

      expect(restored, isNotNull);
      expect(restored!.id, category.id);
      expect(restored.name, 'Food');
      expect(restored.color, category.color);
      expect(restored.isArchived, isFalse);
    });

    test('updates a category and its modification timestamp', () async {
      final category = buildCategory();

      await repository.save(category);

      currentTime = 2000;
      await repository.save(category.archive());

      final query = database.select(database.categories)
        ..where((table) => table.id.equals(category.id.value));
      final row = await query.getSingle();

      expect(row.createdAtMillis, 1000);
      expect(row.updatedAtMillis, 2000);
      expect(row.isArchived, isTrue);
    });

    test('returns all categories', () async {
      await repository.save(buildCategory(id: 'food'));
      await repository.save(buildCategory(id: 'transport'));

      final categories = await repository.getAll();

      expect(categories.map((category) => category.id).toSet(), {
        CategoryId('food'),
        CategoryId('transport'),
      });
    });
  });
}

Category buildCategory({String id = 'category-1'}) {
  return Category(
    id: CategoryId(id),
    name: 'Food',
    color: ArgbColor(0xFFFF9800),
  );
}
