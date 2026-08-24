import 'package:chuspita/app/app.dart';
import 'package:chuspita/app/providers.dart';
import 'package:chuspita/core/color/argb_color.dart';
import 'package:chuspita/features/categories/domain/category.dart';
import 'package:chuspita/features/categories/domain/category_applicability.dart';
import 'package:chuspita/features/categories/domain/category_id.dart';
import 'package:chuspita/features/categories/domain/category_repository.dart';
import 'package:chuspita/features/wallets/application/balance_summary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('opens category management and edits a category', (tester) async {
    final category = buildCategory();
    final repository = FakeCategoryRepository();

    await pumpApp(tester, category: category, repository: repository);
    await tester.tap(find.byTooltip('Gestionar categorías'));
    await tester.pumpAndSettle();

    expect(find.text('Categorías'), findsOneWidget);
    expect(find.text('Alimentación'), findsOneWidget);
    expect(find.text('Gastos e ingresos'), findsOneWidget);

    await tester.tap(find.text('Alimentación'));
    await tester.pumpAndSettle();

    expect(find.text('Editar categoría'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'Transporte');
    await tester.tap(find.widgetWithText(FilledButton, 'Guardar'));
    await tester.pumpAndSettle();

    expect(repository.savedCategory, isNotNull);
    expect(repository.savedCategory!.name, 'Transporte');
    expect(repository.savedCategory!.id, category.id);
  });

  testWidgets('archives a category from its menu', (tester) async {
    final category = buildCategory();
    final repository = FakeCategoryRepository();

    await pumpApp(tester, category: category, repository: repository);
    await tester.tap(find.byTooltip('Gestionar categorías'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Archivar'));
    await tester.pump();

    expect(repository.savedCategory, isNotNull);
    expect(repository.savedCategory!.isArchived, isTrue);
  });
}

Future<void> pumpApp(
  WidgetTester tester, {
  required Category category,
  required FakeCategoryRepository repository,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        balanceSummaryProvider.overrideWithValue(
          AsyncData(BalanceSummary(byWallet: const {}, byCurrency: const {})),
        ),
        transactionsProvider.overrideWithValue(const AsyncData([])),
        categoriesProvider.overrideWithValue(AsyncData([category])),
        categoryRepositoryProvider.overrideWithValue(repository),
      ],
      child: const ChuspitaApp(locale: Locale('es')),
    ),
  );
  await tester.pump();
}

Category buildCategory() {
  return Category(
    id: CategoryId('category-1'),
    name: 'Alimentación',
    color: ArgbColor(0xFFF28C28),
    applicability: CategoryApplicability.both,
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
