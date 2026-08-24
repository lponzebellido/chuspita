import 'dart:math' as math;

import 'package:chuspita/app/formatters/money_formatter.dart';
import 'package:chuspita/core/money/money.dart';
import 'package:chuspita/features/analytics/domain/period_summary.dart';
import 'package:chuspita/l10n/app_localizations_extension.dart';
import 'package:flutter/material.dart';

final class IncomeExpenseSection extends StatelessWidget {
  const IncomeExpenseSection({super.key, required this.summary});

  final PeriodSummary summary;

  @override
  Widget build(BuildContext context) {
    final summaries = summary.byCurrency.values.toList(growable: false)
      ..sort(
        (first, second) => first.currency.code.compareTo(second.currency.code),
      );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.l10n.incomeVsExpensesTitle,
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
                    Icons.bar_chart_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(context.l10n.noPeriodActivity)),
                ],
              ),
            ),
          )
        else
          for (var index = 0; index < summaries.length; index++) ...[
            _IncomeExpenseCard(summary: summaries[index]),
            if (index < summaries.length - 1) const SizedBox(height: 12),
          ],
      ],
    );
  }
}

final class _IncomeExpenseCard extends StatelessWidget {
  const _IncomeExpenseCard({required this.summary});

  final CurrencyPeriodSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final incomeColor = theme.brightness == Brightness.dark
        ? const Color(0xFF81C784)
        : const Color(0xFF2E7D32);
    final expenseColor = theme.colorScheme.error;
    final netColor = switch (summary.net.minorUnits) {
      > 0 => incomeColor,
      < 0 => expenseColor,
      _ => theme.colorScheme.onSurfaceVariant,
    };
    final maximum = math.max(
      summary.income.minorUnits,
      summary.expenses.minorUnits,
    );

    return Semantics(
      key: ValueKey('income-expense-chart-${summary.currency.code}'),
      label:
          '${context.l10n.incomeVsExpensesTitle} · '
          '${summary.currency.code}',
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                summary.currency.code,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 18),
              _ComparisonBar(
                label: context.l10n.monthlyIncome,
                amount: summary.income,
                maximumMinorUnits: maximum,
                color: incomeColor,
              ),
              const SizedBox(height: 16),
              _ComparisonBar(
                label: context.l10n.monthlyExpenses,
                amount: summary.expenses,
                maximumMinorUnits: maximum,
                color: expenseColor,
              ),
              const Divider(height: 32),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      context.l10n.monthlyNet,
                      style: theme.textTheme.titleSmall,
                    ),
                  ),
                  Text(
                    '${_formatAmount(context, summary.net)} '
                    '${summary.currency.code}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: netColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final class _ComparisonBar extends StatelessWidget {
  const _ComparisonBar({
    required this.label,
    required this.amount,
    required this.maximumMinorUnits,
    required this.color,
  });

  final String label;
  final Money amount;
  final int maximumMinorUnits;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final widthFactor = maximumMinorUnits == 0
        ? 0.0
        : amount.minorUnits / maximumMinorUnits;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text(label)),
            Text(
              '${_formatAmount(context, amount)} ${amount.currency.code}',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Container(
            height: 12,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: widthFactor,
              heightFactor: 1,
              child: ColoredBox(color: color),
            ),
          ),
        ),
      ],
    );
  }
}

String _formatAmount(BuildContext context, Money amount) {
  return formatMoneyAmount(
    amount,
    localeName: Localizations.localeOf(context).toString(),
  );
}
