import 'dart:async';

import 'package:chuspita/app/providers.dart';
import 'package:chuspita/core/date/local_date.dart';
import 'package:chuspita/features/analytics/domain/calculate_period_summary.dart';
import 'package:chuspita/features/analytics/presentation/category_spending_section.dart';
import 'package:chuspita/features/analytics/presentation/income_expense_section.dart';
import 'package:chuspita/features/analytics/presentation/spending_metrics_section.dart';
import 'package:chuspita/l10n/app_localizations_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum _StatisticsPeriod { day, week, month, year, custom }

final class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

final class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  late _StatisticsPeriod _period;
  late LocalDate _startDate;
  late LocalDate _endDate;

  @override
  void initState() {
    super.initState();
    _period = _StatisticsPeriod.month;
    final range = _rangeFor(_period, ref.read(currentDateProvider));
    _startDate = range.$1;
    _endDate = range.$2;
  }

  (LocalDate, LocalDate) _rangeFor(
    _StatisticsPeriod period,
    LocalDate currentDate,
  ) {
    final today = DateTime(
      currentDate.year,
      currentDate.month,
      currentDate.day,
    );

    return switch (period) {
      _StatisticsPeriod.day => (currentDate, currentDate),
      _StatisticsPeriod.week => () {
        final start = today.subtract(Duration(days: today.weekday - 1));
        final end = start.add(const Duration(days: 6));

        return (_toLocalDate(start), _toLocalDate(end));
      }(),
      _StatisticsPeriod.month => (
        LocalDate(year: currentDate.year, month: currentDate.month, day: 1),
        LocalDate(
          year: currentDate.year,
          month: currentDate.month,
          day: DateTime(currentDate.year, currentDate.month + 1, 0).day,
        ),
      ),
      _StatisticsPeriod.year => (
        LocalDate(year: currentDate.year, month: 1, day: 1),
        LocalDate(year: currentDate.year, month: 12, day: 31),
      ),
      _StatisticsPeriod.custom => (_startDate, _endDate),
    };
  }

  LocalDate _toLocalDate(DateTime value) {
    return LocalDate(year: value.year, month: value.month, day: value.day);
  }

  void _selectPeriod(_StatisticsPeriod period) {
    if (period == _StatisticsPeriod.custom) {
      unawaited(_selectCustomRange());
      return;
    }

    final range = _rangeFor(period, ref.read(currentDateProvider));

    setState(() {
      _period = period;
      _startDate = range.$1;
      _endDate = range.$2;
    });
  }

  Future<void> _selectCustomRange() async {
    final selected = await showDateRangePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      initialDateRange: DateTimeRange(
        start: DateTime(_startDate.year, _startDate.month, _startDate.day),
        end: DateTime(_endDate.year, _endDate.month, _endDate.day),
      ),
    );

    if (selected != null && mounted) {
      setState(() {
        _period = _StatisticsPeriod.custom;
        _startDate = _toLocalDate(selected.start);
        _endDate = _toLocalDate(selected.end);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final summary = ref
        .watch(transactionsProvider)
        .whenData(
          (transactions) => calculatePeriodSummary(
            transactions: transactions,
            startDate: _startDate,
            endDate: _endDate,
          ),
        );

    Future<void> refresh() {
      return Future.wait<void>([
        ref.refresh(transactionsProvider.future).then((_) {}),
        ref.refresh(categoriesProvider.future).then((_) {}),
      ]);
    }

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.statisticsTitle)),
      body: SafeArea(
        child: switch (summary) {
          AsyncData() => RefreshIndicator(
            onRefresh: refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              children: [
                Text(
                  context.l10n.periodFilter,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: Text(context.l10n.currentDay),
                      selected: _period == _StatisticsPeriod.day,
                      onSelected: (_) => _selectPeriod(_StatisticsPeriod.day),
                    ),
                    ChoiceChip(
                      label: Text(context.l10n.currentWeek),
                      selected: _period == _StatisticsPeriod.week,
                      onSelected: (_) => _selectPeriod(_StatisticsPeriod.week),
                    ),
                    ChoiceChip(
                      label: Text(context.l10n.currentMonth),
                      selected: _period == _StatisticsPeriod.month,
                      onSelected: (_) => _selectPeriod(_StatisticsPeriod.month),
                    ),
                    ChoiceChip(
                      label: Text(context.l10n.currentYear),
                      selected: _period == _StatisticsPeriod.year,
                      onSelected: (_) => _selectPeriod(_StatisticsPeriod.year),
                    ),
                    ChoiceChip(
                      label: Text(context.l10n.customRange),
                      selected: _period == _StatisticsPeriod.custom,
                      onSelected: (_) =>
                          _selectPeriod(_StatisticsPeriod.custom),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _formatRange(context),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 28),
                IncomeExpenseSection(summary: summary.requireValue),
                const SizedBox(height: 28),
                SpendingMetricsSection(
                  summary: summary.requireValue,
                  categories: ref.watch(categoriesProvider).asData?.value ?? [],
                ),
                const SizedBox(height: 28),
                CategorySpendingSection(summary: summary),
              ],
            ),
          ),
          AsyncError() => _StatisticsError(
            onRetry: () => ref.invalidate(transactionsProvider),
          ),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }

  String _formatRange(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final start = localizations.formatMediumDate(
      DateTime(_startDate.year, _startDate.month, _startDate.day),
    );
    final end = localizations.formatMediumDate(
      DateTime(_endDate.year, _endDate.month, _endDate.day),
    );

    return '$start – $end';
  }
}

final class _StatisticsError extends StatelessWidget {
  const _StatisticsError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56),
            const SizedBox(height: 16),
            Text(context.l10n.loadStatisticsError, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: Text(context.l10n.retry)),
          ],
        ),
      ),
    );
  }
}
