import 'package:chuspita/app/formatters/money_formatter.dart';
import 'package:chuspita/core/money/money.dart';
import 'package:chuspita/features/analytics/domain/period_summary.dart';
import 'package:chuspita/l10n/app_localizations_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class MonthlySummarySection extends StatelessWidget {
  const MonthlySummarySection({
    super.key,
    required this.summary,
    required this.onRetry,
  });

  final AsyncValue<PeriodSummary> summary;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.l10n.currentMonth,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        switch (summary) {
          AsyncData(:final value) when value.isEmpty => Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(
                    Icons.insights_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(context.l10n.noMonthlyActivity)),
                ],
              ),
            ),
          ),
          AsyncData(:final value) => _MonthlySummaryCards(summary: value),
          AsyncError() => Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.error_outline),
                  const SizedBox(width: 12),
                  Expanded(child: Text(context.l10n.loadMonthlySummaryError)),
                  TextButton(
                    onPressed: onRetry,
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

final class _MonthlySummaryCards extends StatelessWidget {
  const _MonthlySummaryCards({required this.summary});

  final PeriodSummary summary;

  @override
  Widget build(BuildContext context) {
    final entries = summary.byCurrency.entries.toList(growable: false)
      ..sort((first, second) => first.key.code.compareTo(second.key.code));

    return Column(
      children: [
        for (var index = 0; index < entries.length; index++) ...[
          _MonthlyCurrencyCard(summary: entries[index].value),
          if (index < entries.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

final class _MonthlyCurrencyCard extends StatelessWidget {
  const _MonthlyCurrencyCard({required this.summary});

  final CurrencyPeriodSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final incomeColor = theme.brightness == Brightness.dark
        ? const Color(0xFF81C784)
        : const Color(0xFF2E7D32);
    final netColor = switch (summary.net.minorUnits) {
      > 0 => incomeColor,
      < 0 => theme.colorScheme.error,
      _ => theme.colorScheme.onSurfaceVariant,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              summary.currency.code,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _SummaryMetric(
                    label: context.l10n.monthlyIncome,
                    amount: summary.income,
                    color: incomeColor,
                  ),
                ),
                Expanded(
                  child: _SummaryMetric(
                    label: context.l10n.monthlyExpenses,
                    amount: summary.expenses,
                    color: theme.colorScheme.error,
                  ),
                ),
                Expanded(
                  child: _SummaryMetric(
                    label: context.l10n.monthlyNet,
                    amount: summary.net,
                    color: netColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

final class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.label,
    required this.amount,
    required this.color,
  });

  final String label;
  final Money amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final formattedAmount = formatMoneyAmount(
      amount,
      localeName: Localizations.localeOf(context).toString(),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            '$formattedAmount ${amount.currency.code}',
            style: Theme.of(context).textTheme.titleSmall
                ?.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}
