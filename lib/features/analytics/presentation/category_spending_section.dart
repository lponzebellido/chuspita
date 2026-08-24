import 'dart:math' as math;

import 'package:chuspita/app/formatters/money_formatter.dart';
import 'package:chuspita/app/providers.dart';
import 'package:chuspita/core/money/money.dart';
import 'package:chuspita/features/analytics/domain/period_summary.dart';
import 'package:chuspita/features/categories/domain/category.dart';
import 'package:chuspita/features/categories/domain/category_id.dart';
import 'package:chuspita/l10n/app_localizations_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class CategorySpendingSection extends ConsumerWidget {
  const CategorySpendingSection({super.key, required this.summary});

  final AsyncValue<PeriodSummary> summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final periodSummary = summary.asData?.value;

    if (periodSummary == null) {
      return const SizedBox.shrink();
    }

    final summariesWithExpenses =
        periodSummary.byCurrency.values
            .where((summary) => summary.hasExpenses)
            .toList(growable: false)
          ..sort(
            (first, second) =>
                first.currency.code.compareTo(second.currency.code),
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.l10n.categorySpendingTitle,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        if (summariesWithExpenses.isEmpty)
          _EmptyCategorySpending(message: context.l10n.noCategorySpending)
        else
          switch (ref.watch(categoriesProvider)) {
            AsyncData(:final value) => _CategorySpendingCards(
              summaries: summariesWithExpenses,
              categories: value,
            ),
            AsyncError() => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(context.l10n.loadCategorySpendingError),
                    ),
                    TextButton(
                      onPressed: () => ref.invalidate(categoriesProvider),
                      child: Text(context.l10n.retry),
                    ),
                  ],
                ),
              ),
            ),
            _ => const Card(
              child: Padding(
                padding: EdgeInsets.all(28),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          },
      ],
    );
  }
}

final class _EmptyCategorySpending extends StatelessWidget {
  const _EmptyCategorySpending({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(
              Icons.donut_large_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}

final class _CategorySpendingCards extends StatelessWidget {
  const _CategorySpendingCards({
    required this.summaries,
    required this.categories,
  });

  final List<CurrencyPeriodSummary> summaries;
  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    final categoriesById = <CategoryId, Category>{
      for (final category in categories) category.id: category,
    };

    return Column(
      children: [
        for (var index = 0; index < summaries.length; index++) ...[
          _CategorySpendingCard(
            summary: summaries[index],
            categoriesById: categoriesById,
          ),
          if (index < summaries.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

final class _CategorySpendingCard extends StatelessWidget {
  const _CategorySpendingCard({
    required this.summary,
    required this.categoriesById,
  });

  final CurrencyPeriodSummary summary;
  final Map<CategoryId, Category> categoriesById;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final slices =
        summary.expensesByCategory.entries
            .map((entry) {
              final category = categoriesById[entry.key];

              return _CategoryExpenseSlice(
                name: category?.name ?? context.l10n.unknownCategory,
                amount: entry.value,
                color: category == null
                    ? theme.colorScheme.outline
                    : Color(category.color.value),
              );
            })
            .toList(growable: false)
          ..sort((first, second) {
            final amountComparison = second.amount.minorUnits.compareTo(
              first.amount.minorUnits,
            );

            return amountComparison != 0
                ? amountComparison
                : first.name.toLowerCase().compareTo(second.name.toLowerCase());
          });
    final localeName = Localizations.localeOf(context).toString();
    final total = formatMoneyAmount(summary.expenses, localeName: localeName);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  summary.currency.code,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                const Spacer(),
                Text(
                  '$total ${summary.currency.code}',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final chart = _CategoryDonutChart(
                  currencyCode: summary.currency.code,
                  slices: slices,
                  total: summary.expenses,
                );
                final legend = _CategoryLegend(
                  slices: slices,
                  totalMinorUnits: summary.expenses.minorUnits,
                );

                if (constraints.maxWidth >= 520) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      chart,
                      const SizedBox(width: 28),
                      Expanded(child: legend),
                    ],
                  );
                }

                return Column(
                  children: [chart, const SizedBox(height: 24), legend],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

final class _CategoryDonutChart extends StatelessWidget {
  const _CategoryDonutChart({
    required this.currencyCode,
    required this.slices,
    required this.total,
  });

  final String currencyCode;
  final List<_CategoryExpenseSlice> slices;
  final Money total;

  @override
  Widget build(BuildContext context) {
    final formattedTotal = formatMoneyAmount(
      total,
      localeName: Localizations.localeOf(context).toString(),
    );

    return Semantics(
      key: ValueKey('category-spending-chart-$currencyCode'),
      label: '${context.l10n.categorySpendingTitle} · $currencyCode',
      child: SizedBox.square(
        dimension: 164,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(
              painter: _CategoryDonutPainter(
                slices: slices,
                totalMinorUnits: total.minorUnits,
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(36),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        context.l10n.monthlyExpenses,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      Text(
                        formattedTotal,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _CategoryLegend extends StatelessWidget {
  const _CategoryLegend({required this.slices, required this.totalMinorUnits});

  final List<_CategoryExpenseSlice> slices;
  final int totalMinorUnits;

  @override
  Widget build(BuildContext context) {
    final localeName = Localizations.localeOf(context).toString();

    return Column(
      children: [
        for (var index = 0; index < slices.length; index++) ...[
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: slices[index].color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  slices[index].name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${_percentage(slices[index].amount.minorUnits)} · '
                '${formatMoneyAmount(slices[index].amount, localeName: localeName)} '
                '${slices[index].amount.currency.code}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          if (index < slices.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }

  String _percentage(int minorUnits) {
    return '${(minorUnits * 100 / totalMinorUnits).round()}%';
  }
}

final class _CategoryExpenseSlice {
  const _CategoryExpenseSlice({
    required this.name,
    required this.amount,
    required this.color,
  });

  final String name;
  final Money amount;
  final Color color;
}

final class _CategoryDonutPainter extends CustomPainter {
  const _CategoryDonutPainter({
    required this.slices,
    required this.totalMinorUnits,
  });

  final List<_CategoryExpenseSlice> slices;
  final int totalMinorUnits;

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = math.min(size.width, size.height) * 0.16;
    final rect = Offset.zero & size;
    final arcRect = rect.deflate(strokeWidth / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;
    var startAngle = -math.pi / 2;

    for (final slice in slices) {
      final sweepAngle =
          math.pi * 2 * slice.amount.minorUnits / totalMinorUnits;
      paint.color = slice.color;
      canvas.drawArc(arcRect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(_CategoryDonutPainter oldDelegate) {
    return oldDelegate.slices != slices ||
        oldDelegate.totalMinorUnits != totalMinorUnits;
  }
}
