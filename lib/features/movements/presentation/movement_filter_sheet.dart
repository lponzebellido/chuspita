import 'dart:async';

import 'package:chuspita/core/date/local_date.dart';
import 'package:chuspita/features/categories/domain/category.dart';
import 'package:chuspita/features/categories/domain/category_id.dart';
import 'package:chuspita/features/movements/presentation/movement_filters.dart';
import 'package:chuspita/features/movements/presentation/movement_item.dart';
import 'package:chuspita/features/wallets/domain/wallet.dart';
import 'package:chuspita/features/wallets/domain/wallet_id.dart';
import 'package:chuspita/l10n/app_localizations_extension.dart';
import 'package:flutter/material.dart';

enum _PeriodOption { all, currentMonth, custom }

final class MovementFilterSheet extends StatefulWidget {
  const MovementFilterSheet({
    super.key,
    required this.initialFilters,
    required this.wallets,
    required this.categories,
  });

  final MovementFilters initialFilters;
  final List<Wallet> wallets;
  final List<Category> categories;

  @override
  State<MovementFilterSheet> createState() => _MovementFilterSheetState();
}

final class _MovementFilterSheetState extends State<MovementFilterSheet> {
  MovementType? _type;
  String _walletId = '';
  String _categoryId = '';
  _PeriodOption _period = _PeriodOption.all;
  LocalDate? _startDate;
  LocalDate? _endDate;
  late MovementSortOrder _sortOrder;

  @override
  void initState() {
    super.initState();
    final filters = widget.initialFilters;
    _type = filters.type;
    _walletId = filters.walletId?.value ?? '';
    _categoryId = filters.categoryId?.value ?? '';
    _startDate = filters.startDate;
    _endDate = filters.endDate;
    _sortOrder = filters.sortOrder;
    _period = _periodFor(filters);
  }

  _PeriodOption _periodFor(MovementFilters filters) {
    if (filters.startDate == null) {
      return _PeriodOption.all;
    }

    final currentMonth = _currentMonthRange();

    if (filters.startDate == currentMonth.$1 &&
        filters.endDate == currentMonth.$2) {
      return _PeriodOption.currentMonth;
    }

    return _PeriodOption.custom;
  }

  (LocalDate, LocalDate) _currentMonthRange() {
    final today = DateTime.now();
    final lastDay = DateTime(today.year, today.month + 1, 0).day;

    return (
      LocalDate(year: today.year, month: today.month, day: 1),
      LocalDate(year: today.year, month: today.month, day: lastDay),
    );
  }

  void _selectPeriod(_PeriodOption period) {
    switch (period) {
      case _PeriodOption.all:
        setState(() {
          _period = period;
          _startDate = null;
          _endDate = null;
        });
        return;
      case _PeriodOption.currentMonth:
        final range = _currentMonthRange();
        setState(() {
          _period = period;
          _startDate = range.$1;
          _endDate = range.$2;
        });
        return;
      case _PeriodOption.custom:
        unawaited(_selectCustomRange());
        return;
    }
  }

  Future<void> _selectCustomRange() async {
    final initialRange = _startDate == null
        ? null
        : DateTimeRange(
            start: DateTime(
              _startDate!.year,
              _startDate!.month,
              _startDate!.day,
            ),
            end: DateTime(_endDate!.year, _endDate!.month, _endDate!.day),
          );
    final selected = await showDateRangePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      initialDateRange: initialRange,
    );

    if (selected != null) {
      setState(() {
        _period = _PeriodOption.custom;
        _startDate = LocalDate(
          year: selected.start.year,
          month: selected.start.month,
          day: selected.start.day,
        );
        _endDate = LocalDate(
          year: selected.end.year,
          month: selected.end.month,
          day: selected.end.day,
        );
      });
    }
  }

  void _reset() {
    setState(() {
      _type = null;
      _walletId = '';
      _categoryId = '';
      _period = _PeriodOption.all;
      _startDate = null;
      _endDate = null;
      _sortOrder = MovementSortOrder.newestFirst;
    });
  }

  void _selectType(MovementType? type) {
    var categoryId = _categoryId;

    if (type == MovementType.transfer) {
      categoryId = '';
    } else if (type != null && categoryId.isNotEmpty) {
      final selectedCategory = widget.categories
          .where((category) => category.id.value == categoryId)
          .firstOrNull;

      if (selectedCategory != null &&
          !_categoryAllowsType(selectedCategory, type)) {
        categoryId = '';
      }
    }

    setState(() {
      _type = type;
      _categoryId = categoryId;
    });
  }

  void _apply() {
    Navigator.of(context).pop(
      MovementFilters(
        type: _type,
        walletId: _walletId.isEmpty ? null : WalletId(_walletId),
        categoryId: _categoryId.isEmpty ? null : CategoryId(_categoryId),
        startDate: _startDate,
        endDate: _endDate,
        sortOrder: _sortOrder,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wallets = widget.wallets.toList()
      ..sort(
        (first, second) =>
            first.name.toLowerCase().compareTo(second.name.toLowerCase()),
      );
    final categories =
        widget.categories
            .where(
              (category) =>
                  _type == null ||
                  category.id.value == _categoryId ||
                  _categoryAllowsType(category, _type!),
            )
            .toList()
          ..sort(
            (first, second) =>
                first.name.toLowerCase().compareTo(second.name.toLowerCase()),
          );

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.l10n.filterTransactionsTitle,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            Text(
              context.l10n.transactionTypeFilter,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: Text(context.l10n.allOption),
                  selected: _type == null,
                  onSelected: (_) => _selectType(null),
                ),
                ChoiceChip(
                  label: Text(context.l10n.expense),
                  selected: _type == MovementType.expense,
                  onSelected: (_) => _selectType(MovementType.expense),
                ),
                ChoiceChip(
                  label: Text(context.l10n.income),
                  selected: _type == MovementType.income,
                  onSelected: (_) => _selectType(MovementType.income),
                ),
                ChoiceChip(
                  label: Text(context.l10n.transfer),
                  selected: _type == MovementType.transfer,
                  onSelected: (_) => _selectType(MovementType.transfer),
                ),
              ],
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              key: ValueKey('wallet-$_walletId'),
              initialValue: _walletId,
              decoration: InputDecoration(
                labelText: context.l10n.walletLabel,
                border: const OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(
                  value: '',
                  child: Text(context.l10n.allWallets),
                ),
                for (final wallet in wallets)
                  DropdownMenuItem(
                    value: wallet.id.value,
                    child: Text('${wallet.name} · ${wallet.currency.code}'),
                  ),
              ],
              onChanged: (value) => setState(() => _walletId = value ?? ''),
            ),
            if (_type != MovementType.transfer) ...[
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                key: ValueKey('category-$_categoryId'),
                initialValue: _categoryId,
                decoration: InputDecoration(
                  labelText: context.l10n.categoryLabel,
                  border: const OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(
                    value: '',
                    child: Text(context.l10n.allCategories),
                  ),
                  for (final category in categories)
                    DropdownMenuItem(
                      value: category.id.value,
                      child: Text(category.name),
                    ),
                ],
                onChanged: (value) => setState(() => _categoryId = value ?? ''),
              ),
            ],
            const SizedBox(height: 24),
            Text(
              context.l10n.periodFilter,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: Text(context.l10n.allTime),
                  selected: _period == _PeriodOption.all,
                  onSelected: (_) => _selectPeriod(_PeriodOption.all),
                ),
                ChoiceChip(
                  label: Text(context.l10n.currentMonth),
                  selected: _period == _PeriodOption.currentMonth,
                  onSelected: (_) => _selectPeriod(_PeriodOption.currentMonth),
                ),
                ChoiceChip(
                  label: Text(context.l10n.customRange),
                  selected: _period == _PeriodOption.custom,
                  onSelected: (_) => _selectPeriod(_PeriodOption.custom),
                ),
              ],
            ),
            if (_period == _PeriodOption.custom && _startDate != null) ...[
              const SizedBox(height: 12),
              Text(
                _formatRange(context),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 24),
            Text(
              context.l10n.sortOrderLabel,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: Text(context.l10n.newestFirst),
                  selected: _sortOrder == MovementSortOrder.newestFirst,
                  onSelected: (_) => setState(
                    () => _sortOrder = MovementSortOrder.newestFirst,
                  ),
                ),
                ChoiceChip(
                  label: Text(context.l10n.oldestFirst),
                  selected: _sortOrder == MovementSortOrder.oldestFirst,
                  onSelected: (_) => setState(
                    () => _sortOrder = MovementSortOrder.oldestFirst,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                TextButton(
                  onPressed: _reset,
                  child: Text(context.l10n.resetFilters),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: _apply,
                  child: Text(context.l10n.applyFilters),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatRange(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final start = localizations.formatMediumDate(
      DateTime(_startDate!.year, _startDate!.month, _startDate!.day),
    );
    final end = localizations.formatMediumDate(
      DateTime(_endDate!.year, _endDate!.month, _endDate!.day),
    );

    return '$start – $end';
  }
}

bool _categoryAllowsType(Category category, MovementType type) {
  return switch (type) {
    MovementType.expense => category.applicability.allowsExpenses,
    MovementType.income => category.applicability.allowsIncome,
    MovementType.transfer => false,
  };
}
