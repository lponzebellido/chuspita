import 'package:chuspita/app/formatters/money_formatter.dart';
import 'package:chuspita/core/currency/currency.dart';
import 'package:chuspita/core/date/local_date.dart';
import 'package:chuspita/core/money/money.dart';
import 'package:chuspita/features/analytics/domain/period_summary.dart';
import 'package:chuspita/l10n/app_localizations_extension.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final class PeriodComparisonSection extends StatelessWidget {
  const PeriodComparisonSection({
    super.key,
    required this.current,
    required this.previous,
  });

  final PeriodSummary current;
  final PeriodSummary previous;

  @override
  Widget build(BuildContext context) {
    final currencies =
        <Currency>{
            ...current.byCurrency.keys,
            ...previous.byCurrency.keys,
          }.toList(growable: false)
          ..sort((first, second) => first.code.compareTo(second.code));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.l10n.periodComparisonTitle,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 4),
        Text(
          '${context.l10n.previousPeriod}: ${_formatRange(context, previous)}',
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        if (currencies.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(
                    Icons.compare_arrows,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(context.l10n.noPeriodComparison)),
                ],
              ),
            ),
          )
        else
          for (var index = 0; index < currencies.length; index++) ...[
            _PeriodComparisonCard(
              currency: currencies[index],
              current: current.byCurrency[currencies[index]],
              previous: previous.byCurrency[currencies[index]],
            ),
            if (index < currencies.length - 1) const SizedBox(height: 12),
          ],
      ],
    );
  }
}

final class _PeriodComparisonCard extends StatelessWidget {
  const _PeriodComparisonCard({
    required this.currency,
    required this.current,
    required this.previous,
  });

  final Currency currency;
  final CurrencyPeriodSummary? current;
  final CurrencyPeriodSummary? previous;

  @override
  Widget build(BuildContext context) {
    final zero = Money(minorUnits: 0, currency: currency);

    return Card(
      key: ValueKey('period-comparison-${currency.code}'),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              currency.code,
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 16),
            _ComparisonRow(
              key: ValueKey('income-comparison-${currency.code}'),
              label: context.l10n.monthlyIncome,
              current: current?.income ?? zero,
              previous: previous?.income ?? zero,
              higherIsBetter: true,
            ),
            const Divider(height: 28),
            _ComparisonRow(
              key: ValueKey('expense-comparison-${currency.code}'),
              label: context.l10n.monthlyExpenses,
              current: current?.expenses ?? zero,
              previous: previous?.expenses ?? zero,
              higherIsBetter: false,
            ),
          ],
        ),
      ),
    );
  }
}

final class _ComparisonRow extends StatelessWidget {
  const _ComparisonRow({
    super.key,
    required this.label,
    required this.current,
    required this.previous,
    required this.higherIsBetter,
  });

  final String label;
  final Money current;
  final Money previous;
  final bool higherIsBetter;

  @override
  Widget build(BuildContext context) {
    final difference = current.minorUnits - previous.minorUnits;
    final change = _formatChange(context, current, previous);
    final changeColor = _changeColor(
      context,
      difference: difference,
      higherIsBetter: higherIsBetter,
      hasReference: previous.minorUnits != 0,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Text(
                _formatMoney(context, current),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                change,
                textAlign: TextAlign.end,
                style: Theme.of(context).textTheme.labelMedium
                    ?.copyWith(color: changeColor),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${context.l10n.previousPeriod}: ${_formatMoney(context, previous)}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

String _formatChange(BuildContext context, Money current, Money previous) {
  if (previous.minorUnits == 0) {
    return current.minorUnits == 0
        ? context.l10n.unchangedFromPrevious
        : context.l10n.noPreviousReference;
  }

  final difference = current.minorUnits - previous.minorUnits;

  if (difference == 0) {
    return context.l10n.unchangedFromPrevious;
  }

  final percentage = difference.abs() * 100 / previous.minorUnits;
  final formatter = NumberFormat.decimalPattern(
    Localizations.localeOf(context).toString(),
  )..maximumFractionDigits = 1;
  final direction = difference > 0
      ? context.l10n.moreThanPrevious
      : context.l10n.lessThanPrevious;

  return '${formatter.format(percentage)}% $direction';
}

Color _changeColor(
  BuildContext context, {
  required int difference,
  required bool higherIsBetter,
  required bool hasReference,
}) {
  final theme = Theme.of(context);

  if (!hasReference || difference == 0) {
    return theme.colorScheme.onSurfaceVariant;
  }

  final isFavorable = (difference > 0) == higherIsBetter;

  if (!isFavorable) {
    return theme.colorScheme.error;
  }

  return theme.brightness == Brightness.dark
      ? const Color(0xFF81C784)
      : const Color(0xFF2E7D32);
}

String _formatMoney(BuildContext context, Money amount) {
  return '${formatMoneyAmount(amount, localeName: Localizations.localeOf(context).toString())} '
      '${amount.currency.code}';
}

String _formatRange(BuildContext context, PeriodSummary summary) {
  final localizations = MaterialLocalizations.of(context);
  final start = _toDateTime(summary.startDate);
  final end = _toDateTime(summary.endDate);

  return '${localizations.formatMediumDate(start)} – '
      '${localizations.formatMediumDate(end)}';
}

DateTime _toDateTime(LocalDate date) {
  return DateTime(date.year, date.month, date.day);
}
