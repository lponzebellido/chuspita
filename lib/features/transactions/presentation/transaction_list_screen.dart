import 'package:chuspita/app/formatters/money_formatter.dart';
import 'package:chuspita/app/providers.dart';
import 'package:chuspita/features/categories/domain/category.dart';
import 'package:chuspita/features/categories/domain/category_id.dart';
import 'package:chuspita/features/transactions/domain/transaction.dart';
import 'package:chuspita/features/transactions/presentation/transaction_form_screen.dart';
import 'package:chuspita/features/wallets/domain/wallet.dart';
import 'package:chuspita/features/wallets/domain/wallet_id.dart';
import 'package:chuspita/l10n/app_localizations_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class TransactionListScreen extends ConsumerWidget {
  const TransactionListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionsProvider);
    final wallets = ref.watch(walletsProvider);
    final categories = ref.watch(categoriesProvider);

    Future<void> refresh() {
      return Future.wait<void>([
        ref.refresh(transactionsProvider.future).then((_) {}),
        ref.refresh(walletsProvider.future).then((_) {}),
        ref.refresh(categoriesProvider.future).then((_) {}),
      ]);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.transactionsTitle),
        actions: [
          IconButton(
            tooltip: context.l10n.addTransaction,
            onPressed: () => _openForm(context),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: _buildBody(
        context: context,
        ref: ref,
        transactions: transactions,
        wallets: wallets,
        categories: categories,
        onRefresh: refresh,
      ),
    );
  }

  Widget _buildBody({
    required BuildContext context,
    required WidgetRef ref,
    required AsyncValue<List<Transaction>> transactions,
    required AsyncValue<List<Wallet>> wallets,
    required AsyncValue<List<Category>> categories,
    required RefreshCallback onRefresh,
  }) {
    if (transactions.isLoading || wallets.isLoading || categories.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (transactions.hasError || wallets.hasError || categories.hasError) {
      return _LoadError(
        onRetry: () {
          ref.invalidate(transactionsProvider);
          ref.invalidate(walletsProvider);
          ref.invalidate(categoriesProvider);
        },
      );
    }

    final transactionValues = transactions.requireValue.toList()
      ..sort((first, second) => second.occurredOn.compareTo(first.occurredOn));
    final walletsById = <WalletId, Wallet>{
      for (final wallet in wallets.requireValue) wallet.id: wallet,
    };
    final categoriesById = <CategoryId, Category>{
      for (final category in categories.requireValue) category.id: category,
    };

    if (transactionValues.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyTransactions(onAdd: () => _openForm(context)),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        itemCount: transactionValues.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final transaction = transactionValues[index];
          final wallet = walletsById[transaction.walletId];
          final category = categoriesById[transaction.categoryId];

          return _TransactionTile(
            transaction: transaction,
            walletName: wallet?.name ?? context.l10n.unknownWallet,
            categoryName: category?.name ?? context.l10n.unknownCategory,
            categoryColor: category == null
                ? Theme.of(context).colorScheme.outline
                : Color(category.color.value),
            onTap: () => _openForm(context, transaction: transaction),
          );
        },
      ),
    );
  }

  void _openForm(BuildContext context, {Transaction? transaction}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => TransactionFormScreen(transaction: transaction),
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
    final formattedDate = MaterialLocalizations.of(context).formatMediumDate(
      DateTime(
        transaction.occurredOn.year,
        transaction.occurredOn.month,
        transaction.occurredOn.day,
      ),
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

final class _EmptyTransactions extends StatelessWidget {
  const _EmptyTransactions({required this.onAdd});

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
