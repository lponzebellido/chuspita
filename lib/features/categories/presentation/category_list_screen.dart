import 'package:chuspita/app/providers.dart';
import 'package:chuspita/features/categories/domain/category.dart';
import 'package:chuspita/features/categories/domain/category_applicability.dart';
import 'package:chuspita/features/categories/presentation/category_form_screen.dart';
import 'package:chuspita/l10n/app_localizations_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum _CategoryAction { edit, archive, restore }

final class CategoryListScreen extends ConsumerWidget {
  const CategoryListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.categoriesTitle),
        actions: [
          IconButton(
            tooltip: context.l10n.addCategory,
            onPressed: () => _openForm(context),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: categories.when(
        data: (value) => _CategoryList(
          categories: value,
          onEdit: (category) => _openForm(context, category: category),
          onToggleArchive: (category) => _toggleArchive(context, ref, category),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 56),
                const SizedBox(height: 16),
                Text(context.l10n.loadDataError, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => ref.invalidate(categoriesProvider),
                  child: Text(context.l10n.retry),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openForm(BuildContext context, {Category? category}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => CategoryFormScreen(category: category),
      ),
    );
  }

  Future<void> _toggleArchive(
    BuildContext context,
    WidgetRef ref,
    Category category,
  ) async {
    try {
      final updateCategory = ref.read(updateCategoryProvider);

      if (category.isArchived) {
        await updateCategory.restore(category);
      } else {
        await updateCategory.archive(category);
      }

      ref.invalidate(categoriesProvider);
    } on Object {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.saveCategoryError)));
      }
    }
  }
}

final class _CategoryList extends StatelessWidget {
  const _CategoryList({
    required this.categories,
    required this.onEdit,
    required this.onToggleArchive,
  });

  final List<Category> categories;
  final ValueChanged<Category> onEdit;
  final ValueChanged<Category> onToggleArchive;

  @override
  Widget build(BuildContext context) {
    final sortedCategories = categories.toList(growable: false)
      ..sort((first, second) {
        if (first.isArchived != second.isArchived) {
          return first.isArchived ? 1 : -1;
        }

        return first.name.toLowerCase().compareTo(second.name.toLowerCase());
      });

    if (sortedCategories.isEmpty) {
      return Center(child: Text(context.l10n.noCategoriesTitle));
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      itemCount: sortedCategories.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final category = sortedCategories[index];
        final color = Color(category.color.value);
        final applicabilityLabel = switch (category.applicability) {
          CategoryApplicability.expense => context.l10n.categoryExpenseOption,
          CategoryApplicability.income => context.l10n.categoryIncomeOption,
          CategoryApplicability.both => context.l10n.categoryBothDescription,
        };

        return Opacity(
          opacity: category.isArchived ? 0.6 : 1,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 6,
            ),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.category_outlined, color: color),
            ),
            title: Text(category.name),
            subtitle: Text(
              category.isArchived
                  ? '$applicabilityLabel · ${context.l10n.archived}'
                  : applicabilityLabel,
            ),
            onTap: () => onEdit(category),
            trailing: PopupMenuButton<_CategoryAction>(
              onSelected: (action) {
                switch (action) {
                  case _CategoryAction.edit:
                    onEdit(category);
                    return;
                  case _CategoryAction.archive:
                  case _CategoryAction.restore:
                    onToggleArchive(category);
                    return;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: _CategoryAction.edit,
                  child: Text(context.l10n.edit),
                ),
                PopupMenuItem(
                  value: category.isArchived
                      ? _CategoryAction.restore
                      : _CategoryAction.archive,
                  child: Text(
                    category.isArchived
                        ? context.l10n.restore
                        : context.l10n.archive,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
