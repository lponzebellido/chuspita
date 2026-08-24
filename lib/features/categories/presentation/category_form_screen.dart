import 'package:chuspita/app/providers.dart';
import 'package:chuspita/core/color/argb_color.dart';
import 'package:chuspita/features/categories/domain/category.dart';
import 'package:chuspita/features/categories/domain/category_applicability.dart';
import 'package:chuspita/features/categories/presentation/category_color_palette.dart';
import 'package:chuspita/l10n/app_localizations_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class CategoryFormScreen extends ConsumerStatefulWidget {
  const CategoryFormScreen({super.key, this.category});

  final Category? category;

  @override
  ConsumerState<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

final class _CategoryFormScreenState extends ConsumerState<CategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late Color _selectedColor;
  late CategoryApplicability _applicability;
  bool _isSaving = false;
  String? _saveError;

  @override
  void initState() {
    super.initState();
    final category = widget.category;
    _nameController = TextEditingController(text: category?.name);
    _selectedColor = category == null
        ? CategoryColorPalette.values.first
        : Color(category.color.value);
    _applicability = category?.applicability ?? CategoryApplicability.both;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
      _saveError = null;
    });

    try {
      final color = ArgbColor(_selectedColor.toARGB32());
      final category = widget.category;

      if (category == null) {
        await ref
            .read(createCategoryProvider)
            .call(
              name: _nameController.text,
              color: color,
              applicability: _applicability,
            );
      } else {
        await ref
            .read(updateCategoryProvider)
            .details(
              category: category,
              name: _nameController.text,
              color: color,
              applicability: _applicability,
            );
      }

      ref.invalidate(categoriesProvider);

      if (mounted) {
        Navigator.of(context).pop();
      }
    } on Object {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _saveError = context.l10n.saveCategoryError;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isEditing = widget.category != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? l10n.editCategoryTitle : l10n.newCategoryTitle),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          children: [
            TextFormField(
              controller: _nameController,
              autofocus: !isEditing,
              enabled: !_isSaving,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l10n.categoryNameLabel,
                hintText: l10n.categoryNameHint,
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.categoryNameRequired;
                }

                return null;
              },
            ),
            const SizedBox(height: 28),
            Text(
              l10n.categoryApplicabilityLabel,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            SegmentedButton<CategoryApplicability>(
              segments: [
                ButtonSegment(
                  value: CategoryApplicability.expense,
                  label: Text(l10n.categoryExpenseOption),
                ),
                ButtonSegment(
                  value: CategoryApplicability.income,
                  label: Text(l10n.categoryIncomeOption),
                ),
                ButtonSegment(
                  value: CategoryApplicability.both,
                  label: Text(l10n.categoryBothOption),
                ),
              ],
              selected: {_applicability},
              showSelectedIcon: false,
              onSelectionChanged: _isSaving
                  ? null
                  : (selection) =>
                        setState(() => _applicability = selection.first),
            ),
            const SizedBox(height: 28),
            Text(
              l10n.categoryColorLabel,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final (index, color)
                    in CategoryColorPalette.values.indexed)
                  _ColorOption(
                    color: color,
                    label: '${l10n.categoryColorLabel} ${index + 1}',
                    isSelected: color.toARGB32() == _selectedColor.toARGB32(),
                    onSelected: _isSaving
                        ? null
                        : () => setState(() => _selectedColor = color),
                  ),
              ],
            ),
            if (_saveError != null) ...[
              const SizedBox(height: 24),
              Text(
                _saveError!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: FilledButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.save),
        ),
      ),
    );
  }
}

final class _ColorOption extends StatelessWidget {
  const _ColorOption({
    required this.color,
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  final Color color;
  final String label;
  final bool isSelected;
  final VoidCallback? onSelected;

  @override
  Widget build(BuildContext context) {
    final checkColor = color.computeLuminance() > 0.45
        ? Colors.black
        : Colors.white;

    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: InkResponse(
        onTap: onSelected,
        radius: 28,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.onSurface
                  : Colors.transparent,
              width: 3,
            ),
          ),
          child: isSelected ? Icon(Icons.check, color: checkColor) : null,
        ),
      ),
    );
  }
}
