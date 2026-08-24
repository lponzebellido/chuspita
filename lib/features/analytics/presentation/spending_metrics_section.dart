import 'package:chuspita/app/formatters/money_formatter.dart';
import 'package:chuspita/core/money/money.dart';
import 'package:chuspita/features/analytics/domain/period_summary.dart';
import 'package:chuspita/features/categories/domain/category.dart';
import 'package:chuspita/features/categories/domain/category_id.dart';
import 'package:chuspita/l10n/app_localizations_extension.dart';
import 'package:flutter/material.dart';

final class SpendingMetricsSection extends StatelessWidget {
  const SpendingMetricsSection({
    super.key,
    required this.summary,
    required this.categories,
  });

  final PeriodSummary summary;
  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    final summaries =
        summary.byCurrency.values
            .where((summary) => summary.hasExpenses)
            .toList(growable: false)
          ..sort(
            (first, second) =>
                first.currency.code.compareTo(second.currency.code),
          );
    final categoriesById = <CategoryId, Category>{
      for (final category in categories) category.id: category,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.l10n.spendingMetricsTitle,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        if (summaries.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(
                    Icons.query_stats_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(context.l10n.noExpenseMetrics)),
                ],
              ),
            ),
          )
        else
          for (var index = 0; index < summaries.length; index++) ...[
            _SpendingMetricsCard(
              summary: summaries[index],
              categoriesById: categoriesById,
            ),
            if (index < summaries.length - 1) const SizedBox(height: 12),
          ],
      ],
    );
  }
}

final class _SpendingMetricsCard extends StatelessWidget {
  const _SpendingMetricsCard({
    required this.summary,
    required this.categoriesById,
  });

  final CurrencyPeriodSummary summary;
  final Map<CategoryId, Category> categoriesById;

  @override
  Widget build(BuildContext context) {
    final topCategory = summary.topExpenseCategory!;
    final topCategoryName =
        categoriesById[topCategory.key]?.name ?? context.l10n.unknownCategory;

    return Card(
      key: ValueKey('spending-metrics-${summary.currency.code}'),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              summary.currency.code,
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final metrics = [
                  _MetricData(
                    key: ValueKey(
                      'expense-count-metric-${summary.currency.code}',
                    ),
                    label: context.l10n.expenseCountMetric,
                    value: '${summary.expenseCount}',
                  ),
                  _MetricData(
                    key: ValueKey(
                      'average-expense-metric-${summary.currency.code}',
                    ),
                    label: context.l10n.averageExpenseMetric,
                    value: _formatMoney(context, summary.averageExpense),
                  ),
                  _MetricData(
                    key: ValueKey(
                      'largest-expense-metric-${summary.currency.code}',
                    ),
                    label: context.l10n.largestExpenseMetric,
                    value: _formatMoney(context, summary.largestExpense),
                  ),
                  _MetricData(
                    key: ValueKey(
                      'top-category-metric-${summary.currency.code}',
                    ),
                    label: context.l10n.topCategoryMetric,
                    value: topCategoryName,
                    detail: _formatMoney(context, topCategory.value),
                  ),
                ];

                if (constraints.maxWidth >= 600) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var index = 0; index < metrics.length; index++) ...[
                        Expanded(child: _MetricTile(data: metrics[index])),
                        if (index < metrics.length - 1)
                          const SizedBox(width: 10),
                      ],
                    ],
                  );
                }

                return Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _MetricTile(data: metrics[0])),
                        const SizedBox(width: 10),
                        Expanded(child: _MetricTile(data: metrics[1])),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _MetricTile(data: metrics[2])),
                        const SizedBox(width: 10),
                        Expanded(child: _MetricTile(data: metrics[3])),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

final class _MetricData {
  const _MetricData({
    required this.key,
    required this.label,
    required this.value,
    this.detail,
  });

  final Key key;
  final String label;
  final String value;
  final String? detail;
}

final class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.data});

  final _MetricData data;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      key: data.key,
      constraints: const BoxConstraints(minHeight: 92),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 6),
          Text(
            data.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (data.detail != null) ...[
            const SizedBox(height: 2),
            Text(
              data.detail!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

String _formatMoney(BuildContext context, Money amount) {
  return '${formatMoneyAmount(amount, localeName: Localizations.localeOf(context).toString())} '
      '${amount.currency.code}';
}
