import 'package:chuspita/app/formatters/money_formatter.dart';
import 'package:chuspita/app/providers.dart';
import 'package:chuspita/core/date/local_date.dart';
import 'package:chuspita/core/date/local_time.dart';
import 'package:chuspita/features/categories/domain/category.dart';
import 'package:chuspita/features/categories/domain/category_id.dart';
import 'package:chuspita/features/movements/presentation/movement_filter_sheet.dart';
import 'package:chuspita/features/movements/presentation/movement_filters.dart';
import 'package:chuspita/features/movements/presentation/movement_item.dart';
import 'package:chuspita/features/transactions/domain/transaction.dart';
import 'package:chuspita/features/transactions/presentation/transaction_form_screen.dart';
import 'package:chuspita/features/transfers/domain/transfer.dart';
import 'package:chuspita/features/transfers/presentation/transfer_form_screen.dart';
import 'package:chuspita/features/wallets/domain/wallet.dart';
import 'package:chuspita/features/wallets/domain/wallet_id.dart';
import 'package:chuspita/l10n/app_localizations_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class MovementListScreen extends ConsumerStatefulWidget {
  const MovementListScreen({super.key});

  @override
  ConsumerState<MovementListScreen> createState() => _MovementListScreenState();
}

final class _MovementListScreenState extends ConsumerState<MovementListScreen> {
  late MovementFilters _filters;

  @override
  void initState() {
    super.initState();
    _filters = MovementFilters();
  }

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionsProvider);
    final transfers = ref.watch(transfersProvider);
    final wallets = ref.watch(walletsProvider);
    final categories = ref.watch(categoriesProvider);
    final currentDate = ref.watch(currentDateProvider);

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
        title: Text(context.l10n.transactionsTitle),
        actions: [
          IconButton(
            tooltip: context.l10n.filterTransactionsTitle,
            onPressed: wallets.hasValue && categories.hasValue
                ? () => _openFilters(
                    wallets.requireValue,
                    categories.requireValue,
                  )
                : null,
            icon: Badge(
              isLabelVisible: !_filters.isEmpty,
              label: Text('${_filters.activeCount}'),
              child: const Icon(Icons.filter_list),
            ),
          ),
          IconButton(
            tooltip: context.l10n.addTransaction,
            onPressed: () => _openTransactionForm(context),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: _buildBody(
        context: context,
        ref: ref,
        transactions: transactions,
        transfers: transfers,
        wallets: wallets,
        categories: categories,
        currentDate: currentDate,
        onRefresh: refresh,
      ),
    );
  }

  Widget _buildBody({
    required BuildContext context,
    required WidgetRef ref,
    required AsyncValue<List<Transaction>> transactions,
    required AsyncValue<List<Transfer>> transfers,
    required AsyncValue<List<Wallet>> wallets,
    required AsyncValue<List<Category>> categories,
    required LocalDate currentDate,
    required RefreshCallback onRefresh,
  }) {
    if (transactions.isLoading ||
        transfers.isLoading ||
        wallets.isLoading ||
        categories.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (transactions.hasError ||
        transfers.hasError ||
        wallets.hasError ||
        categories.hasError) {
      return _LoadError(
        onRetry: () {
          ref.invalidate(transactionsProvider);
          ref.invalidate(transfersProvider);
          ref.invalidate(walletsProvider);
          ref.invalidate(categoriesProvider);
        },
      );
    }

    final allMovements = combineMovements(
      transactions: transactions.requireValue,
      transfers: transfers.requireValue,
    );
    final movementValues = _filters.apply(allMovements);
    final walletsById = <WalletId, Wallet>{
      for (final wallet in wallets.requireValue) wallet.id: wallet,
    };
    final categoriesById = <CategoryId, Category>{
      for (final category in categories.requireValue) category.id: category,
    };

    if (allMovements.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyMovements(
                onAdd: () => _openTransactionForm(context),
              ),
            ),
          ],
        ),
      );
    }

    if (movementValues.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyFilteredMovements(
                onClear: () => setState(() => _filters = MovementFilters()),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        itemCount: movementValues.length + (_filters.isEmpty ? 0 : 1),
        itemBuilder: (context, index) {
          if (!_filters.isEmpty && index == 0) {
            return Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => setState(() => _filters = MovementFilters()),
                icon: const Icon(Icons.filter_list_off),
                label: Text(context.l10n.clearFilters),
              ),
            );
          }

          final movementIndex = index - (_filters.isEmpty ? 0 : 1);
          final movement = movementValues[movementIndex];
          final beginsDateGroup =
              movementIndex == 0 ||
              movementValues[movementIndex - 1].occurredOn !=
                  movement.occurredOn;
          final continuesDateGroup =
              movementIndex < movementValues.length - 1 &&
              movementValues[movementIndex + 1].occurredOn ==
                  movement.occurredOn;

          return Column(
            children: [
              if (beginsDateGroup)
                _MovementDateHeader(
                  date: movement.occurredOn,
                  currentDate: currentDate,
                  isFirst: movementIndex == 0,
                ),
              switch (movement) {
                TransactionMovementItem(:final transaction) => _TransactionTile(
                  transaction: transaction,
                  walletName:
                      walletsById[transaction.walletId]?.name ??
                      context.l10n.unknownWallet,
                  categoryName:
                      categoriesById[transaction.categoryId]?.name ??
                      context.l10n.unknownCategory,
                  categoryColor: categoriesById[transaction.categoryId] == null
                      ? Theme.of(context).colorScheme.outline
                      : Color(
                          categoriesById[transaction.categoryId]!.color.value,
                        ),
                  onTap: () =>
                      _openTransactionForm(context, transaction: transaction),
                ),
                TransferMovementItem(:final transfer) => _TransferTile(
                  transfer: transfer,
                  sourceWalletName:
                      walletsById[transfer.sourceWalletId]?.name ??
                      context.l10n.unknownWallet,
                  destinationWalletName:
                      walletsById[transfer.destinationWalletId]?.name ??
                      context.l10n.unknownWallet,
                  onTap: () => _openTransferDetails(
                    transfer: transfer,
                    sourceWalletName:
                        walletsById[transfer.sourceWalletId]?.name ??
                        context.l10n.unknownWallet,
                    destinationWalletName:
                        walletsById[transfer.destinationWalletId]?.name ??
                        context.l10n.unknownWallet,
                  ),
                ),
              },
              if (continuesDateGroup) const Divider(height: 1),
            ],
          );
        },
      ),
    );
  }

  Future<void> _openFilters(
    List<Wallet> wallets,
    List<Category> categories,
  ) async {
    final selected = await showModalBottomSheet<MovementFilters>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => MovementFilterSheet(
        initialFilters: _filters,
        wallets: wallets,
        categories: categories,
      ),
    );

    if (selected != null && mounted) {
      setState(() => _filters = selected);
    }
  }

  void _openTransactionForm(BuildContext context, {Transaction? transaction}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => TransactionFormScreen(transaction: transaction),
      ),
    );
  }

  void _openTransferDetails({
    required Transfer transfer,
    required String sourceWalletName,
    required String destinationWalletName,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _TransferDetails(
        transfer: transfer,
        sourceWalletName: sourceWalletName,
        destinationWalletName: destinationWalletName,
        onEdit: () => _editTransfer(transfer),
        onDelete: () => _deleteTransfer(transfer),
      ),
    );
  }

  void _editTransfer(Transfer transfer) {
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => TransferFormScreen(transfer: transfer),
      ),
    );
  }

  Future<void> _deleteTransfer(Transfer transfer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.deleteTransferTitle),
        content: Text(context.l10n.deleteTransferConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    try {
      await ref.read(deleteTransferProvider).call(transfer);
      ref.invalidate(transfersProvider);
      ref.invalidate(balanceSummaryProvider);

      if (mounted) {
        Navigator.of(context).pop();
      }
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.deleteTransferError)),
        );
      }
    }
  }
}

final class _MovementDateHeader extends StatelessWidget {
  const _MovementDateHeader({
    required this.date,
    required this.currentDate,
    required this.isFirst,
  });

  final LocalDate date;
  final LocalDate currentDate;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      key: ValueKey('movement-date-header-$date'),
      padding: EdgeInsets.fromLTRB(8, isFirst ? 4 : 24, 8, 6),
      child: Row(
        children: [
          Text(
            _formatMovementDateHeader(context, date, currentDate),
            style: Theme.of(context).textTheme.titleSmall
                ?.copyWith(color: colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(child: Divider(color: colorScheme.outlineVariant)),
        ],
      ),
    );
  }
}

final class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.transaction,
    required this.walletName,
    required this.categoryName,
    required this.categoryColor,
    required this.onTap,
  });

  final Transaction transaction;
  final String walletName;
  final String categoryName;
  final Color categoryColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final amountColor = isIncome
        ? Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF81C784)
              : const Color(0xFF2E7D32)
        : Theme.of(context).colorScheme.error;
    final formattedAmount = formatMoneyAmount(
      transaction.amount,
      localeName: Localizations.localeOf(context).toString(),
    );
    final formattedDate = _formatDateTime(
      context,
      transaction.occurredOn,
      transaction.occurredAt,
    );
    final details = [
      if (transaction.note != null) transaction.note!,
      walletName,
      formattedDate,
    ].join(' · ');

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: categoryColor.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          isIncome ? Icons.arrow_downward : Icons.arrow_upward,
          color: categoryColor,
        ),
      ),
      title: Text(categoryName),
      subtitle: Text(details, maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: Text(
        '${isIncome ? '+' : '-'}$formattedAmount '
        '${transaction.amount.currency.code}',
        style: Theme.of(context).textTheme.titleMedium
            ?.copyWith(color: amountColor),
      ),
      onTap: onTap,
    );
  }
}

final class _TransferTile extends StatelessWidget {
  const _TransferTile({
    required this.transfer,
    required this.sourceWalletName,
    required this.destinationWalletName,
    required this.onTap,
  });

  final Transfer transfer;
  final String sourceWalletName;
  final String destinationWalletName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final localeName = Localizations.localeOf(context).toString();
    final sourceAmount = formatMoneyAmount(
      transfer.sourceAmount,
      localeName: localeName,
    );
    final destinationAmount = formatMoneyAmount(
      transfer.destinationAmount,
      localeName: localeName,
    );
    final details = [
      if (transfer.note != null) transfer.note!,
      '$sourceWalletName → $destinationWalletName',
      _formatDateTime(context, transfer.occurredOn, transfer.occurredAt),
    ].join(' · ');
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.swap_horiz, color: colorScheme.onSecondaryContainer),
      ),
      title: Text(context.l10n.transfer),
      subtitle: Text(details, maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('−$sourceAmount ${transfer.sourceAmount.currency.code}'),
          Text(
            '+$destinationAmount ${transfer.destinationAmount.currency.code}',
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}

final class _TransferDetails extends StatelessWidget {
  const _TransferDetails({
    required this.transfer,
    required this.sourceWalletName,
    required this.destinationWalletName,
    required this.onEdit,
    required this.onDelete,
  });

  final Transfer transfer;
  final String sourceWalletName;
  final String destinationWalletName;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final localeName = Localizations.localeOf(context).toString();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.l10n.transfer,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.call_made),
              title: Text(context.l10n.sourceWalletLabel),
              subtitle: Text(sourceWalletName),
              trailing: Text(
                '${formatMoneyAmount(transfer.sourceAmount, localeName: localeName)} '
                '${transfer.sourceAmount.currency.code}',
              ),
            ),
            const Center(child: Icon(Icons.arrow_downward)),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.call_received),
              title: Text(context.l10n.destinationWalletLabel),
              subtitle: Text(destinationWalletName),
              trailing: Text(
                '${formatMoneyAmount(transfer.destinationAmount, localeName: localeName)} '
                '${transfer.destinationAmount.currency.code}',
              ),
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today_outlined),
              title: Text(context.l10n.dateLabel),
              subtitle: Text(
                _formatDateTime(
                  context,
                  transfer.occurredOn,
                  transfer.occurredAt,
                ),
              ),
            ),
            if (transfer.note != null)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.notes),
                title: Text(context.l10n.noteLabel),
                subtitle: Text(transfer.note!),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined),
                    label: Text(context.l10n.edit),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      foregroundColor: Theme.of(context).colorScheme.onError,
                    ),
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline),
                    label: Text(context.l10n.delete),
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

final class _EmptyMovements extends StatelessWidget {
  const _EmptyMovements({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 20),
            Text(
              context.l10n.noTransactionsTitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(context.l10n.noTransactionsBody, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: Text(context.l10n.addTransaction),
            ),
          ],
        ),
      ),
    );
  }
}

final class _EmptyFilteredMovements extends StatelessWidget {
  const _EmptyFilteredMovements({required this.onClear});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.filter_list_off,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 20),
            Text(
              context.l10n.noFilteredTransactionsTitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.noFilteredTransactionsBody,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: onClear,
              child: Text(context.l10n.clearFilters),
            ),
          ],
        ),
      ),
    );
  }
}

final class _LoadError extends StatelessWidget {
  const _LoadError({required this.onRetry});

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
            Text(context.l10n.loadDataError, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: Text(context.l10n.retry)),
          ],
        ),
      ),
    );
  }
}

String _formatDate(BuildContext context, LocalDate date) {
  return MaterialLocalizations.of(context)
      .formatMediumDate(DateTime(date.year, date.month, date.day));
}

String _formatMovementDateHeader(
  BuildContext context,
  LocalDate date,
  LocalDate currentDate,
) {
  if (date == currentDate) {
    return context.l10n.currentDay;
  }

  final yesterdayValue = DateTime.utc(
    currentDate.year,
    currentDate.month,
    currentDate.day,
  ).subtract(const Duration(days: 1));
  final yesterday = LocalDate(
    year: yesterdayValue.year,
    month: yesterdayValue.month,
    day: yesterdayValue.day,
  );

  if (date == yesterday) {
    return context.l10n.yesterday;
  }

  return MaterialLocalizations.of(context)
      .formatFullDate(DateTime(date.year, date.month, date.day));
}

String _formatDateTime(BuildContext context, LocalDate date, LocalTime time) {
  final localizations = MaterialLocalizations.of(context);
  final formattedDate = _formatDate(context, date);
  final formattedTime = localizations.formatTimeOfDay(
    TimeOfDay(hour: time.hour, minute: time.minute),
    alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
  );

  return '$formattedDate · $formattedTime';
}
