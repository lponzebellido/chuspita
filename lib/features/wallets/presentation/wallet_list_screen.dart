import 'package:chuspita/app/providers.dart';
import 'package:chuspita/features/wallets/domain/wallet.dart';
import 'package:chuspita/features/wallets/domain/wallet_deletion_not_allowed.dart';
import 'package:chuspita/features/wallets/presentation/wallet_form_screen.dart';
import 'package:chuspita/l10n/app_localizations_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum _WalletAction { edit, archive, restore, delete }

final class WalletListScreen extends ConsumerWidget {
  const WalletListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallets = ref.watch(walletsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.walletsTitle),
        actions: [
          IconButton(
            tooltip: context.l10n.addWallet,
            onPressed: () => _openForm(context),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: wallets.when(
        data: (value) => _WalletList(
          wallets: value,
          onEdit: (wallet) => _openForm(context, wallet: wallet),
          onToggleArchive: (wallet) => _toggleArchive(context, ref, wallet),
          onDelete: (wallet) => _delete(context, ref, wallet),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 56),
                const SizedBox(height: 16),
                Text(context.l10n.loadDataError, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => ref.invalidate(walletsProvider),
                  child: Text(context.l10n.retry),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openForm(BuildContext context, {Wallet? wallet}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => WalletFormScreen(wallet: wallet),
      ),
    );
  }

  Future<void> _toggleArchive(
    BuildContext context,
    WidgetRef ref,
    Wallet wallet,
  ) async {
    try {
      final updateWallet = ref.read(updateWalletProvider);

      if (wallet.isArchived) {
        await updateWallet.restore(wallet);
      } else {
        await updateWallet.archive(wallet);
      }

      ref.invalidate(walletsProvider);
      ref.invalidate(balanceSummaryProvider);
    } on Object {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.saveWalletError)));
      }
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    Wallet wallet,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.deleteWalletTitle),
        content: Text(context.l10n.deleteWalletConfirmation),
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

    if (confirmed != true || !context.mounted) {
      return;
    }

    try {
      await ref.read(deleteWalletProvider).call(wallet);
      ref.invalidate(walletsProvider);
      ref.invalidate(balanceSummaryProvider);
    } on WalletDeletionNotAllowed {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.deleteWalletHasMovements)),
        );
      }
    } on Object {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.deleteWalletError)));
      }
    }
  }
}

final class _WalletList extends StatelessWidget {
  const _WalletList({
    required this.wallets,
    required this.onEdit,
    required this.onToggleArchive,
    required this.onDelete,
  });

  final List<Wallet> wallets;
  final ValueChanged<Wallet> onEdit;
  final ValueChanged<Wallet> onToggleArchive;
  final ValueChanged<Wallet> onDelete;

  @override
  Widget build(BuildContext context) {
    final sortedWallets = wallets.toList(growable: false)
      ..sort((first, second) {
        if (first.isArchived != second.isArchived) {
          return first.isArchived ? 1 : -1;
        }

        return first.name.toLowerCase().compareTo(second.name.toLowerCase());
      });

    if (sortedWallets.isEmpty) {
      return Center(child: Text(context.l10n.noWalletsTitle));
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      itemCount: sortedWallets.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final wallet = sortedWallets[index];

        return Opacity(
          opacity: wallet.isArchived ? 0.6 : 1,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 6,
            ),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.account_balance_wallet_outlined),
            ),
            title: Text(wallet.name),
            subtitle: Text(
              wallet.isArchived
                  ? '${wallet.currency.code} — ${context.l10n.archived}'
                  : wallet.currency.code,
            ),
            onTap: () => onEdit(wallet),
            trailing: PopupMenuButton<_WalletAction>(
              onSelected: (action) {
                switch (action) {
                  case _WalletAction.edit:
                    onEdit(wallet);
                    return;
                  case _WalletAction.archive:
                  case _WalletAction.restore:
                    onToggleArchive(wallet);
                    return;
                  case _WalletAction.delete:
                    onDelete(wallet);
                    return;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: _WalletAction.edit,
                  child: Text(context.l10n.edit),
                ),
                PopupMenuItem(
                  value: wallet.isArchived
                      ? _WalletAction.restore
                      : _WalletAction.archive,
                  child: Text(
                    wallet.isArchived
                        ? context.l10n.restore
                        : context.l10n.archive,
                  ),
                ),
                PopupMenuItem(
                  value: _WalletAction.delete,
                  child: Text(
                    context.l10n.delete,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
