import 'package:chuspita/app/formatters/money_formatter.dart';
import 'package:chuspita/app/providers.dart';
import 'package:chuspita/core/money/money.dart';
import 'package:chuspita/features/wallets/application/balance_summary.dart';
import 'package:chuspita/features/wallets/presentation/wallet_form_screen.dart';
import 'package:chuspita/features/wallets/presentation/wallet_list_screen.dart';
import 'package:chuspita/l10n/app_localizations_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(balanceSummaryProvider);
    final l10n = context.l10n;

    void openWalletForm() {
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (context) => const WalletFormScreen()),
      );
    }

    void openWalletList() {
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (context) => const WalletListScreen()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appName),
        actions: [
          IconButton(
            tooltip: l10n.manageWallets,
            onPressed: openWalletList,
            icon: const Icon(Icons.account_balance_wallet_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: summary.when(
          data: (value) =>
              _BalanceContent(summary: value, onAddWallet: openWalletForm),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => _ErrorContent(
            onRetry: () => ref.invalidate(balanceSummaryProvider),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: openWalletForm,
        icon: const Icon(Icons.add),
        label: Text(l10n.addWallet),
      ),
    );
  }
}

final class _BalanceContent extends StatelessWidget {
  const _BalanceContent({required this.summary, required this.onAddWallet});

  final BalanceSummary summary;
  final VoidCallback onAddWallet;

  @override
  Widget build(BuildContext context) {
    if (summary.byWallet.isEmpty) {
      return _EmptyContent(onAddWallet: onAddWallet);
    }

    final balances = summary.byCurrency.entries.toList(growable: false)
      ..sort((first, second) => first.key.code.compareTo(second.key.code));

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      children: [
        Text(
          context.l10n.balanceByCurrency,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 20),
        for (final balance in balances) ...[
          _CurrencyBalanceCard(balance: balance.value),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

final class _CurrencyBalanceCard extends StatelessWidget {
  const _CurrencyBalanceCard({required this.balance});

  final Money balance;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.payments_outlined,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              balance.currency.code,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Spacer(),
            Text(
              formatMoneyAmount(
                balance,
                localeName: Localizations.localeOf(context).toString(),
              ),
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      ),
    );
  }
}

final class _EmptyContent extends StatelessWidget {
  const _EmptyContent({required this.onAddWallet});

  final VoidCallback onAddWallet;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 20),
            Text(
              context.l10n.noWalletsTitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.noWalletsBody,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onAddWallet,
              icon: const Icon(Icons.add),
              label: Text(context.l10n.addWallet),
            ),
          ],
        ),
      ),
    );
  }
}

final class _ErrorContent extends StatelessWidget {
  const _ErrorContent({required this.onRetry});

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
            Text(
              context.l10n.loadDataError,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: Text(context.l10n.retry)),
          ],
        ),
      ),
    );
  }
}
