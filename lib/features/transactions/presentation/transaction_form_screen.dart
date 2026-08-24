import 'package:chuspita/app/formatters/money_formatter.dart';
import 'package:chuspita/app/providers.dart';
import 'package:chuspita/core/date/local_date.dart';
import 'package:chuspita/core/money/parse_money.dart';
import 'package:chuspita/features/categories/domain/category.dart';
import 'package:chuspita/features/categories/domain/category_id.dart';
import 'package:chuspita/features/categories/presentation/category_list_screen.dart';
import 'package:chuspita/features/transactions/domain/transaction.dart';
import 'package:chuspita/features/wallets/domain/wallet.dart';
import 'package:chuspita/features/wallets/domain/wallet_id.dart';
import 'package:chuspita/features/wallets/presentation/wallet_list_screen.dart';
import 'package:chuspita/l10n/app_localizations_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class TransactionFormScreen extends ConsumerStatefulWidget {
  const TransactionFormScreen({super.key, this.transaction});

  final Transaction? transaction;

  @override
  ConsumerState<TransactionFormScreen> createState() =>
      _TransactionFormScreenState();
}

final class _TransactionFormScreenState
    extends ConsumerState<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  late TransactionType _type;
  WalletId? _selectedWalletId;
  CategoryId? _selectedCategoryId;
  late LocalDate _occurredOn;
  bool _isSaving = false;
  String? _saveError;

  @override
  void initState() {
    super.initState();
    final transaction = widget.transaction;
    final today = DateTime.now();
    _amountController = TextEditingController(
      text: transaction == null
          ? null
          : formatMoneyAmount(transaction.amount, localeName: 'en'),
    );
    _noteController = TextEditingController(text: transaction?.note);
    _type = transaction?.type ?? TransactionType.expense;
    _selectedWalletId = transaction?.walletId;
    _selectedCategoryId = transaction?.categoryId;
    _occurredOn =
        transaction?.occurredOn ??
        LocalDate(year: today.year, month: today.month, day: today.day);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: DateTime(
        _occurredOn.year,
        _occurredOn.month,
        _occurredOn.day,
      ),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (selected != null) {
      setState(() {
        _occurredOn = LocalDate(
          year: selected.year,
          month: selected.month,
          day: selected.day,
        );
      });
    }
  }

  Future<void> _save(List<Wallet> wallets, List<Category> categories) async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final wallet = _selectedWallet(wallets);
    final category = _selectedCategory(categories);

    setState(() {
      _isSaving = true;
      _saveError = null;
    });

    try {
      final amount = parseMoney(_amountController.text, wallet.currency);
      final transaction = widget.transaction;

      if (transaction == null) {
        await ref
            .read(createTransactionProvider)
            .call(
              type: _type,
              amount: amount,
              walletId: wallet.id,
              categoryId: category.id,
              occurredOn: _occurredOn,
              note: _noteController.text,
            );
      } else {
        await ref
            .read(updateTransactionProvider)
            .call(
              transaction: transaction,
              type: _type,
              amount: amount,
              walletId: wallet.id,
              categoryId: category.id,
              occurredOn: _occurredOn,
              note: _noteController.text,
            );
      }

      ref.invalidate(transactionsProvider);
      ref.invalidate(balanceSummaryProvider);

      if (mounted) {
        Navigator.of(context).pop();
      }
    } on Object {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _saveError = context.l10n.saveTransactionError;
        });
      }
    }
  }

  Future<void> _delete() async {
    final transaction = widget.transaction;

    if (transaction == null) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.deleteTransactionTitle),
        content: Text(context.l10n.deleteTransactionConfirmation),
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

    if (confirmed != true) {
      return;
    }

    setState(() {
      _isSaving = true;
      _saveError = null;
    });

    try {
      await ref.read(deleteTransactionProvider).call(transaction);
      ref.invalidate(transactionsProvider);
      ref.invalidate(balanceSummaryProvider);

      if (mounted) {
        Navigator.of(context).pop();
      }
    } on Object {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _saveError = context.l10n.deleteTransactionError;
        });
      }
    }
  }

  Wallet _selectedWallet(List<Wallet> wallets) {
    return wallets.firstWhere(
      (wallet) => wallet.id == _selectedWalletId,
      orElse: () => wallets.first,
    );
  }

  Category _selectedCategory(List<Category> categories) {
    return categories.firstWhere(
      (category) => category.id == _selectedCategoryId,
      orElse: () => categories.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    final wallets = ref.watch(walletsProvider);
    final categories = ref.watch(categoriesProvider);
    final transaction = widget.transaction;
    final activeWallets =
        wallets.asData?.value
            .where(
              (wallet) =>
                  !wallet.isArchived || wallet.id == transaction?.walletId,
            )
            .toList() ??
        const <Wallet>[];
    final activeCategories =
        categories.asData?.value
            .where(
              (category) =>
                  !category.isArchived ||
                  category.id == transaction?.categoryId,
            )
            .toList() ??
        const <Category>[];
    final dataLoaded = wallets.hasValue && categories.hasValue;
    final canSave =
        dataLoaded && activeWallets.isNotEmpty && activeCategories.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          transaction == null
              ? context.l10n.newTransactionTitle
              : context.l10n.editTransactionTitle,
        ),
        actions: [
          if (transaction != null)
            IconButton(
              tooltip: context.l10n.delete,
              onPressed: _isSaving ? null : _delete,
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: _buildBody(
        wallets: wallets,
        categories: categories,
        activeWallets: activeWallets,
        activeCategories: activeCategories,
      ),
      bottomNavigationBar: canSave
          ? SafeArea(
              minimum: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: FilledButton(
                onPressed: _isSaving
                    ? null
                    : () => _save(activeWallets, activeCategories),
                child: _isSaving
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(context.l10n.save),
              ),
            )
          : null,
    );
  }

  Widget _buildBody({
    required AsyncValue<List<Wallet>> wallets,
    required AsyncValue<List<Category>> categories,
    required List<Wallet> activeWallets,
    required List<Category> activeCategories,
  }) {
    if (wallets.isLoading || categories.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (wallets.hasError || categories.hasError) {
      return _LoadError(
        onRetry: () {
          ref.invalidate(walletsProvider);
          ref.invalidate(categoriesProvider);
        },
      );
    }

    if (activeWallets.isEmpty || activeCategories.isEmpty) {
      return _MissingRequirements(
        needsWallet: activeWallets.isEmpty,
        needsCategory: activeCategories.isEmpty,
        onManageWallets: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) => const WalletListScreen(),
          ),
        ),
        onManageCategories: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) => const CategoryListScreen(),
          ),
        ),
      );
    }

    activeWallets.sort(
      (first, second) =>
          first.name.toLowerCase().compareTo(second.name.toLowerCase()),
    );
    activeCategories.sort(
      (first, second) =>
          first.name.toLowerCase().compareTo(second.name.toLowerCase()),
    );

    final selectedWallet = _selectedWallet(activeWallets);
    final selectedCategory = _selectedCategory(activeCategories);

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        children: [
          SegmentedButton<TransactionType>(
            segments: [
              ButtonSegment(
                value: TransactionType.expense,
                label: Text(context.l10n.expense),
                icon: const Icon(Icons.arrow_upward),
              ),
              ButtonSegment(
                value: TransactionType.income,
                label: Text(context.l10n.income),
                icon: const Icon(Icons.arrow_downward),
              ),
            ],
            selected: {_type},
            onSelectionChanged: _isSaving
                ? null
                : (selection) => setState(() => _type = selection.first),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _amountController,
            autofocus: true,
            enabled: !_isSaving,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: context.l10n.amountLabel,
              suffixText: selectedWallet.currency.code,
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              try {
                final amount = parseMoney(value ?? '', selectedWallet.currency);

                if (amount.minorUnits <= 0) {
                  return context.l10n.transactionAmountInvalid;
                }

                return null;
              } on FormatException {
                return context.l10n.transactionAmountInvalid;
              }
            },
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<WalletId>(
            initialValue: selectedWallet.id,
            decoration: InputDecoration(
              labelText: context.l10n.walletLabel,
              border: const OutlineInputBorder(),
            ),
            items: [
              for (final wallet in activeWallets)
                DropdownMenuItem(
                  value: wallet.id,
                  child: Text('${wallet.name} · ${wallet.currency.code}'),
                ),
            ],
            onChanged: _isSaving
                ? null
                : (walletId) {
                    if (walletId != null) {
                      setState(() => _selectedWalletId = walletId);
                    }
                  },
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<CategoryId>(
            initialValue: selectedCategory.id,
            decoration: InputDecoration(
              labelText: context.l10n.categoryLabel,
              border: const OutlineInputBorder(),
            ),
            items: [
              for (final category in activeCategories)
                DropdownMenuItem(
                  value: category.id,
                  child: Row(
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Color(category.color.value),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(category.name),
                    ],
                  ),
                ),
            ],
            onChanged: _isSaving
                ? null
                : (categoryId) {
                    if (categoryId != null) {
                      setState(() => _selectedCategoryId = categoryId);
                    }
                  },
          ),
          const SizedBox(height: 20),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 4),
            leading: const Icon(Icons.calendar_today_outlined),
            title: Text(context.l10n.dateLabel),
            subtitle: Text(
              MaterialLocalizations.of(context).formatMediumDate(
                DateTime(_occurredOn.year, _occurredOn.month, _occurredOn.day),
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: _isSaving ? null : _selectDate,
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _noteController,
            enabled: !_isSaving,
            textCapitalization: TextCapitalization.sentences,
            minLines: 2,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: context.l10n.noteLabel,
              hintText: context.l10n.noteHint,
              border: const OutlineInputBorder(),
            ),
          ),
          if (_saveError != null) ...[
            const SizedBox(height: 24),
            Text(
              _saveError!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      ),
    );
  }
}

final class _MissingRequirements extends StatelessWidget {
  const _MissingRequirements({
    required this.needsWallet,
    required this.needsCategory,
    required this.onManageWallets,
    required this.onManageCategories,
  });

  final bool needsWallet;
  final bool needsCategory;
  final VoidCallback onManageWallets;
  final VoidCallback onManageCategories;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            if (needsWallet) ...[
              const SizedBox(height: 20),
              Text(
                context.l10n.transactionNeedsWallet,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: onManageWallets,
                child: Text(context.l10n.manageWallets),
              ),
            ],
            if (needsCategory) ...[
              const SizedBox(height: 20),
              Text(
                context.l10n.transactionNeedsCategory,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: onManageCategories,
                child: Text(context.l10n.manageCategories),
              ),
            ],
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
