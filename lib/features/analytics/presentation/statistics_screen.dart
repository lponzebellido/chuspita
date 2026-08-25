import 'dart:async';

import 'package:chuspita/app/providers.dart';
import 'package:chuspita/core/date/local_date.dart';
import 'package:chuspita/features/analytics/domain/analytics_period.dart';
import 'package:chuspita/features/analytics/domain/calculate_period_summary.dart';
import 'package:chuspita/features/analytics/domain/period_summary.dart';
import 'package:chuspita/features/analytics/presentation/category_spending_section.dart';
import 'package:chuspita/features/analytics/presentation/expense_trend_section.dart';
import 'package:chuspita/features/analytics/presentation/income_expense_section.dart';
import 'package:chuspita/features/analytics/presentation/period_comparison_section.dart';
import 'package:chuspita/features/analytics/presentation/spending_metrics_section.dart';
import 'package:chuspita/features/export/data/csv_financial_exporter.dart';
import 'package:chuspita/features/export/data/xlsx_financial_exporter.dart';
import 'package:chuspita/l10n/app_localizations_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum _ExportFormat { xlsx, csv }

final class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

final class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  late AnalyticsPeriod _period;
  late LocalDate _startDate;
  late LocalDate _endDate;
  var _isExporting = false;

  @override
  void initState() {
    super.initState();
    _period = AnalyticsPeriod.month;
    final range = _rangeFor(_period, ref.read(currentDateProvider));
    _startDate = range.$1;
    _endDate = range.$2;
  }

  (LocalDate, LocalDate) _rangeFor(
    AnalyticsPeriod period,
    LocalDate currentDate,
  ) {
    final today = DateTime(
      currentDate.year,
      currentDate.month,
      currentDate.day,
    );

    return switch (period) {
      AnalyticsPeriod.day => (currentDate, currentDate),
      AnalyticsPeriod.week => () {
        final start = today.subtract(Duration(days: today.weekday - 1));
        final end = start.add(const Duration(days: 6));

        return (_toLocalDate(start), _toLocalDate(end));
      }(),
      AnalyticsPeriod.month => (
        LocalDate(year: currentDate.year, month: currentDate.month, day: 1),
        LocalDate(
          year: currentDate.year,
          month: currentDate.month,
          day: DateTime(currentDate.year, currentDate.month + 1, 0).day,
        ),
      ),
      AnalyticsPeriod.year => (
        LocalDate(year: currentDate.year, month: 1, day: 1),
        LocalDate(year: currentDate.year, month: 12, day: 31),
      ),
      AnalyticsPeriod.custom => (_startDate, _endDate),
    };
  }

  LocalDate _toLocalDate(DateTime value) {
    return LocalDate(year: value.year, month: value.month, day: value.day);
  }

  void _selectPeriod(AnalyticsPeriod period) {
    if (period == AnalyticsPeriod.custom) {
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
        _period = AnalyticsPeriod.custom;
        _startDate = _toLocalDate(selected.start);
        _endDate = _toLocalDate(selected.end);
      });
    }
  }

  Future<void> _export(
    BuildContext shareAnchorContext,
    PeriodSummary summary,
    _ExportFormat format,
  ) async {
    final renderObject = shareAnchorContext.findRenderObject();
    final sharePositionOrigin = renderObject is RenderBox
        ? renderObject.localToGlobal(Offset.zero) & renderObject.size
        : null;

    setState(() => _isExporting = true);

    try {
      final transactions = await ref.read(transactionsProvider.future);
      final transfers = await ref.read(transfersProvider.future);
      final categories = await ref.read(categoriesProvider.future);
      final wallets = await ref.read(walletsProvider.future);
      final file = switch (format) {
        _ExportFormat.xlsx => buildFinancialXlsx(
          summary: summary,
          transactions: transactions,
          transfers: transfers,
          categories: categories,
          wallets: wallets,
        ),
        _ExportFormat.csv => buildFinancialCsv(
          summary: summary,
          transactions: transactions,
          transfers: transfers,
          categories: categories,
          wallets: wallets,
        ),
      };
      await ref
          .read(exportShareServiceProvider)
          .share(file, sharePositionOrigin: sharePositionOrigin);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.exportDataError)));
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionsProvider);
    final previousPeriod = previousEquivalentPeriod(
      period: _period,
      startDate: _startDate,
      endDate: _endDate,
    );
    final summaries = transactions.whenData(
      (transactions) => (
        current: calculatePeriodSummary(
          transactions: transactions,
          startDate: _startDate,
          endDate: _endDate,
        ),
        previous: calculatePeriodSummary(
          transactions: transactions,
          startDate: previousPeriod.startDate,
          endDate: previousPeriod.endDate,
        ),
      ),
    );

    Future<void> refresh() {
      return Future.wait<void>([
        ref.refresh(transactionsProvider.future).then((_) {}),
        ref.refresh(transfersProvider.future).then((_) {}),
        ref.refresh(walletsProvider.future).then((_) {}),
        ref.refresh(categoriesProvider.future).then((_) {}),
      ]);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.statisticsTitle),
        actions: [
          Builder(
            builder: (shareAnchorContext) {
              if (_isExporting) {
                return IconButton(
                  tooltip: context.l10n.exportData,
                  onPressed: null,
                  icon: const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }

              return PopupMenuButton<_ExportFormat>(
                tooltip: context.l10n.exportData,
                enabled: summaries.hasValue,
                icon: const Icon(Icons.file_download_outlined),
                onSelected: (format) {
                  final summary = summaries.asData?.value.current;

                  if (summary != null) {
                    unawaited(_export(shareAnchorContext, summary, format));
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: _ExportFormat.xlsx,
                    child: Row(
                      children: [
                        const Icon(Icons.table_chart_outlined),
                        const SizedBox(width: 12),
                        Text(context.l10n.exportXlsx),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: _ExportFormat.csv,
                    child: Row(
                      children: [
                        const Icon(Icons.text_snippet_outlined),
                        const SizedBox(width: 12),
                        Text(context.l10n.exportCsv),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: switch (summaries) {
          AsyncData(:final value) => RefreshIndicator(
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
                      selected: _period == AnalyticsPeriod.day,
                      onSelected: (_) => _selectPeriod(AnalyticsPeriod.day),
                    ),
                    ChoiceChip(
                      label: Text(context.l10n.currentWeek),
                      selected: _period == AnalyticsPeriod.week,
                      onSelected: (_) => _selectPeriod(AnalyticsPeriod.week),
                    ),
                    ChoiceChip(
                      label: Text(context.l10n.currentMonth),
                      selected: _period == AnalyticsPeriod.month,
                      onSelected: (_) => _selectPeriod(AnalyticsPeriod.month),
                    ),
                    ChoiceChip(
                      label: Text(context.l10n.currentYear),
                      selected: _period == AnalyticsPeriod.year,
                      onSelected: (_) => _selectPeriod(AnalyticsPeriod.year),
                    ),
                    ChoiceChip(
                      label: Text(context.l10n.customRange),
                      selected: _period == AnalyticsPeriod.custom,
                      onSelected: (_) => _selectPeriod(AnalyticsPeriod.custom),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _formatRange(context),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 28),
                IncomeExpenseSection(summary: value.current),
                const SizedBox(height: 28),
                SpendingMetricsSection(
                  summary: value.current,
                  categories: ref.watch(categoriesProvider).asData?.value ?? [],
                ),
                const SizedBox(height: 28),
                PeriodComparisonSection(
                  current: value.current,
                  previous: value.previous,
                ),
                const SizedBox(height: 28),
                ExpenseTrendSection(summary: value.current),
                const SizedBox(height: 28),
                CategorySpendingSection(summary: AsyncData(value.current)),
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
