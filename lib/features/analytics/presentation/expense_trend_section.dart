import 'dart:math' as math;

import 'package:chuspita/app/formatters/money_formatter.dart';
import 'package:chuspita/core/date/local_date.dart';
import 'package:chuspita/core/money/money.dart';
import 'package:chuspita/features/analytics/domain/period_summary.dart';
import 'package:chuspita/l10n/app_localizations_extension.dart';
import 'package:flutter/material.dart';

final class ExpenseTrendSection extends StatelessWidget {
  const ExpenseTrendSection({super.key, required this.summary});

  final PeriodSummary summary;

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.l10n.expenseTrendTitle,
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
                    Icons.show_chart,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(context.l10n.noExpenseTrend)),
                ],
              ),
            ),
          )
        else
          for (var index = 0; index < summaries.length; index++) ...[
            _ExpenseTrendCard(
              period: summary,
              currencySummary: summaries[index],
            ),
            if (index < summaries.length - 1) const SizedBox(height: 12),
          ],
      ],
    );
  }
}

final class _ExpenseTrendCard extends StatelessWidget {
  const _ExpenseTrendCard({
    required this.period,
    required this.currencySummary,
  });

  final PeriodSummary period;
  final CurrencyPeriodSummary currencySummary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trend = _buildTrend(period, currencySummary);
    final groupingLabel = switch (trend.granularity) {
      _TrendGranularity.day => context.l10n.expenseTrendGroupedByDay,
      _TrendGranularity.week => context.l10n.expenseTrendGroupedByWeek,
      _TrendGranularity.month => context.l10n.expenseTrendGroupedByMonth,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    currencySummary.currency.code,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                Text(
                  _formatMoney(context, currencySummary.expenses),
                  style: theme.textTheme.labelLarge,
                ),
              ],
            ),
            const SizedBox(height: 18),
            Semantics(
              key: ValueKey(
                'expense-trend-chart-${currencySummary.currency.code}',
              ),
              label:
                  '${context.l10n.expenseTrendTitle} · '
                  '${currencySummary.currency.code} · $groupingLabel',
              child: SizedBox(
                height: 160,
                child: CustomPaint(
                  painter: _ExpenseTrendPainter(
                    values: [
                      for (final bucket in trend.buckets)
                        bucket.amountMinorUnits,
                    ],
                    barColor: theme.colorScheme.primary,
                    gridColor: theme.colorScheme.outlineVariant,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(_formatDate(context, period.startDate)),
                const Spacer(),
                Text(_formatDate(context, period.endDate)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              groupingLabel,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _ExpenseTrendPainter extends CustomPainter {
  const _ExpenseTrendPainter({
    required this.values,
    required this.barColor,
    required this.gridColor,
  });

  final List<int> values;
  final Color barColor;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty || size.isEmpty) {
      return;
    }

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    for (var line = 0; line <= 3; line++) {
      final y = size.height * line / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final maximum = values.reduce(math.max);

    if (maximum == 0) {
      return;
    }

    final slotWidth = size.width / values.length;
    final barWidth = math.min(28.0, math.max(2.0, slotWidth * 0.68));
    final barPaint = Paint()..color = barColor;

    for (var index = 0; index < values.length; index++) {
      final value = values[index];

      if (value == 0) {
        continue;
      }

      final proportionalHeight = size.height * value / maximum;
      final height = math.max(2.0, proportionalHeight);
      final left = index * slotWidth + (slotWidth - barWidth) / 2;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, size.height - height, barWidth, height),
        const Radius.circular(3),
      );

      canvas.drawRRect(rect, barPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ExpenseTrendPainter oldDelegate) {
    if (barColor != oldDelegate.barColor ||
        gridColor != oldDelegate.gridColor ||
        values.length != oldDelegate.values.length) {
      return true;
    }

    for (var index = 0; index < values.length; index++) {
      if (values[index] != oldDelegate.values[index]) {
        return true;
      }
    }

    return false;
  }
}

enum _TrendGranularity { day, week, month }

final class _ExpenseTrend {
  const _ExpenseTrend({required this.granularity, required this.buckets});

  final _TrendGranularity granularity;
  final List<_ExpenseBucket> buckets;
}

final class _ExpenseBucket {
  const _ExpenseBucket({
    required this.startDate,
    required this.endDate,
    required this.amountMinorUnits,
  });

  final LocalDate startDate;
  final LocalDate endDate;
  final int amountMinorUnits;
}

_ExpenseTrend _buildTrend(PeriodSummary period, CurrencyPeriodSummary summary) {
  final start = _toDateTime(period.startDate);
  final end = _toDateTime(period.endDate);
  final dayCount = end.difference(start).inDays + 1;
  final granularity = switch (dayCount) {
    <= 31 => _TrendGranularity.day,
    <= 180 => _TrendGranularity.week,
    _ => _TrendGranularity.month,
  };
  final buckets = <_ExpenseBucket>[];
  var bucketStart = start;

  while (!bucketStart.isAfter(end)) {
    final nextStart = switch (granularity) {
      _TrendGranularity.day => bucketStart.add(const Duration(days: 1)),
      _TrendGranularity.week => bucketStart.add(const Duration(days: 7)),
      _TrendGranularity.month => DateTime.utc(
        bucketStart.year,
        bucketStart.month + 1,
      ),
    };
    final bucketEnd = nextStart.subtract(const Duration(days: 1)).isAfter(end)
        ? end
        : nextStart.subtract(const Duration(days: 1));
    final localStart = _toLocalDate(bucketStart);
    final localEnd = _toLocalDate(bucketEnd);
    var amountMinorUnits = 0;

    for (final entry in summary.expensesByDate.entries) {
      if (entry.key.compareTo(localStart) >= 0 &&
          entry.key.compareTo(localEnd) <= 0) {
        amountMinorUnits += entry.value.minorUnits;
      }
    }

    buckets.add(
      _ExpenseBucket(
        startDate: localStart,
        endDate: localEnd,
        amountMinorUnits: amountMinorUnits,
      ),
    );
    bucketStart = nextStart;
  }

  return _ExpenseTrend(granularity: granularity, buckets: buckets);
}

DateTime _toDateTime(LocalDate date) {
  return DateTime.utc(date.year, date.month, date.day);
}

LocalDate _toLocalDate(DateTime date) {
  return LocalDate(year: date.year, month: date.month, day: date.day);
}

String _formatDate(BuildContext context, LocalDate date) {
  return MaterialLocalizations.of(context)
      .formatShortDate(DateTime(date.year, date.month, date.day));
}

String _formatMoney(BuildContext context, Money amount) {
  return '${formatMoneyAmount(amount, localeName: Localizations.localeOf(context).toString())} '
      '${amount.currency.code}';
}
