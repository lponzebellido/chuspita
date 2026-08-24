import 'package:chuspita/app/formatters/money_formatter.dart';
import 'package:chuspita/app/providers.dart';
import 'package:chuspita/core/date/local_date.dart';
import 'package:chuspita/core/money/money.dart';
import 'package:chuspita/core/money/parse_money.dart';
import 'package:chuspita/features/transfers/application/find_latest_exchange_rate.dart';
import 'package:chuspita/features/transfers/domain/exchange_rate.dart';
import 'package:chuspita/features/transfers/domain/transfer.dart';
import 'package:chuspita/features/wallets/domain/wallet.dart';
import 'package:chuspita/features/wallets/domain/wallet_id.dart';
import 'package:chuspita/features/wallets/presentation/wallet_list_screen.dart';
import 'package:chuspita/l10n/app_localizations_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class TransferFormScreen extends ConsumerStatefulWidget {
  const TransferFormScreen({super.key});

  @override
  ConsumerState<TransferFormScreen> createState() => _TransferFormScreenState();
}

final class _TransferFormScreenState extends ConsumerState<TransferFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _sourceAmountController = TextEditingController();
  final _destinationAmountController = TextEditingController();
  final _exchangeRateController = TextEditingController();
  final _noteController = TextEditingController();
  WalletId? _sourceWalletId;
  WalletId? _destinationWalletId;
  late LocalDate _occurredOn;
  bool _useExchangeRate = true;
  bool _hasSuggestedRate = false;
  bool _isSynchronizingRate = false;
  String? _ratePair;
  bool _isSaving = false;
  String? _saveError;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _occurredOn = LocalDate(
      year: today.year,
      month: today.month,
      day: today.day,
    );
    _sourceAmountController.addListener(_refreshConversionPreview);
    _exchangeRateController.addListener(_refreshConversionPreview);
  }

  @override
  void dispose() {
    _sourceAmountController.dispose();
    _destinationAmountController.dispose();
    _exchangeRateController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _refreshConversionPreview() {
    if (mounted && !_isSynchronizingRate) {
      setState(() {});
    }
  }

  Wallet _selectedSource(List<Wallet> wallets) {
    return wallets.firstWhere(
      (wallet) => wallet.id == _sourceWalletId,
      orElse: () => wallets.first,
    );
  }

  Wallet _selectedDestination(List<Wallet> wallets, Wallet source) {
    return wallets.firstWhere(
      (wallet) => wallet.id == _destinationWalletId && wallet.id != source.id,
      orElse: () => wallets.firstWhere((wallet) => wallet.id != source.id),
    );
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

  Future<void> _save(List<Wallet> wallets) async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final sourceWallet = _selectedSource(wallets);
    final destinationWallet = _selectedDestination(wallets, sourceWallet);
    final sourceAmount = parseMoney(
      _sourceAmountController.text,
      sourceWallet.currency,
    );
    final isCurrencyExchange =
        sourceWallet.currency != destinationWallet.currency;
    final destinationAmount = !isCurrencyExchange
        ? sourceAmount
        : _useExchangeRate
        ? ExchangeRate.parse(
            value: _exchangeRateController.text,
            sourceCurrency: sourceWallet.currency,
            destinationCurrency: destinationWallet.currency,
          ).convert(sourceAmount)
        : parseMoney(
            _destinationAmountController.text,
            destinationWallet.currency,
          );

    setState(() {
      _isSaving = true;
      _saveError = null;
    });

    try {
      await ref
          .read(createTransferProvider)
          .call(
            sourceWalletId: sourceWallet.id,
            destinationWalletId: destinationWallet.id,
            sourceAmount: sourceAmount,
            destinationAmount: destinationAmount,
            occurredOn: _occurredOn,
            note: _noteController.text,
          );

      ref.invalidate(balanceSummaryProvider);
      ref.invalidate(transfersProvider);

      if (mounted) {
        Navigator.of(context).pop();
      }
    } on Object {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _saveError = context.l10n.saveTransferError;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final wallets = ref.watch(walletsProvider);
    final transfers = ref.watch(transfersProvider);
    final activeWallets =
        wallets.asData?.value.where((wallet) => !wallet.isArchived).toList() ??
        const <Wallet>[];

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.newTransferTitle)),
      body: _buildBody(
        wallets: wallets,
        transfers: transfers,
        activeWallets: activeWallets,
      ),
      bottomNavigationBar: wallets.hasValue && activeWallets.length >= 2
          ? SafeArea(
              minimum: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: FilledButton(
                onPressed: _isSaving ? null : () => _save(activeWallets),
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
    required AsyncValue<List<Transfer>> transfers,
    required List<Wallet> activeWallets,
  }) {
    if (wallets.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (wallets.hasError) {
      return _LoadError(onRetry: () => ref.invalidate(walletsProvider));
    }

    if (activeWallets.length < 2) {
      return _MissingWallets(
        onManageWallets: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) => const WalletListScreen(),
          ),
        ),
      );
    }

    activeWallets.sort(
      (first, second) =>
          first.name.toLowerCase().compareTo(second.name.toLowerCase()),
    );
    final sourceWallet = _selectedSource(activeWallets);
    final destinationWallet = _selectedDestination(activeWallets, sourceWallet);
    final isCurrencyExchange =
        sourceWallet.currency != destinationWallet.currency;

    if (isCurrencyExchange && transfers.hasValue) {
      _synchronizeSuggestedRate(
        sourceWallet: sourceWallet,
        destinationWallet: destinationWallet,
        transfers: transfers.requireValue,
      );
    }

    final calculatedDestination = isCurrencyExchange && _useExchangeRate
        ? _calculateDestinationAmount(sourceWallet, destinationWallet)
        : null;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        children: [
          DropdownButtonFormField<WalletId>(
            key: ValueKey('source-${sourceWallet.id.value}'),
            initialValue: sourceWallet.id,
            decoration: InputDecoration(
              labelText: context.l10n.sourceWalletLabel,
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
                      setState(() {
                        _sourceWalletId = walletId;

                        if (_destinationWalletId == walletId) {
                          _destinationWalletId = null;
                        }

                        _ratePair = null;
                      });
                    }
                  },
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Icon(Icons.arrow_downward),
          ),
          DropdownButtonFormField<WalletId>(
            key: ValueKey(
              'destination-${sourceWallet.id.value}-'
              '${destinationWallet.id.value}',
            ),
            initialValue: destinationWallet.id,
            decoration: InputDecoration(
              labelText: context.l10n.destinationWalletLabel,
              border: const OutlineInputBorder(),
            ),
            items: [
              for (final wallet in activeWallets)
                if (wallet.id != sourceWallet.id)
                  DropdownMenuItem(
                    value: wallet.id,
                    child: Text('${wallet.name} · ${wallet.currency.code}'),
                  ),
            ],
            onChanged: _isSaving
                ? null
                : (walletId) {
                    if (walletId != null) {
                      setState(() {
                        _destinationWalletId = walletId;
                        _ratePair = null;
                      });
                    }
                  },
          ),
          const SizedBox(height: 24),
          TextFormField(
            key: const ValueKey('transfer-source-amount'),
            controller: _sourceAmountController,
            autofocus: true,
            enabled: !_isSaving,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: isCurrencyExchange
                ? TextInputAction.next
                : TextInputAction.done,
            decoration: InputDecoration(
              labelText: context.l10n.sourceAmountLabel,
              suffixText: sourceWallet.currency.code,
              border: const OutlineInputBorder(),
            ),
            validator: (value) => _validateAmount(
              value,
              sourceWallet,
              context.l10n.transferAmountInvalid,
            ),
          ),
          if (isCurrencyExchange) ...[
            const SizedBox(height: 20),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: _useExchangeRate,
              onChanged: _isSaving
                  ? null
                  : (value) => setState(() => _useExchangeRate = value),
              secondary: const Icon(Icons.currency_exchange),
              title: Text(context.l10n.useExchangeRate),
              subtitle: Text(context.l10n.approximateExchangeRateWarning),
            ),
            if (_useExchangeRate) ...[
              const SizedBox(height: 4),
              Text(
                _hasSuggestedRate
                    ? context.l10n.lastSavedExchangeRate
                    : context.l10n.noSavedExchangeRate,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const ValueKey('transfer-exchange-rate'),
                controller: _exchangeRateController,
                enabled: !_isSaving,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: context.l10n.exchangeRateLabel,
                  prefixText: '1 ${sourceWallet.currency.code} = ',
                  suffixText: destinationWallet.currency.code,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) => _validateExchangeRate(
                  value,
                  sourceWallet,
                  destinationWallet,
                  context.l10n.exchangeRateInvalid,
                ),
              ),
              if (calculatedDestination != null) ...[
                const SizedBox(height: 12),
                Card(
                  margin: EdgeInsets.zero,
                  child: ListTile(
                    leading: const Icon(Icons.calculate_outlined),
                    title: Text(context.l10n.calculatedDestinationAmount),
                    trailing: Text(
                      '${formatMoneyAmount(calculatedDestination, localeName: Localizations.localeOf(context).toString())} ${destinationWallet.currency.code}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
              ],
            ] else ...[
              const SizedBox(height: 16),
              TextFormField(
                key: const ValueKey('transfer-destination-amount'),
                controller: _destinationAmountController,
                enabled: !_isSaving,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: context.l10n.destinationAmountLabel,
                  suffixText: destinationWallet.currency.code,
                  helperText: context.l10n.crossCurrencyTransferHint,
                  helperMaxLines: 2,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) => _validateAmount(
                  value,
                  destinationWallet,
                  context.l10n.transferAmountInvalid,
                ),
              ),
            ],
          ],
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
            key: const ValueKey('transfer-note'),
            controller: _noteController,
            enabled: !_isSaving,
            textCapitalization: TextCapitalization.sentences,
            minLines: 2,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: context.l10n.noteLabel,
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

  String? _validateAmount(String? value, Wallet wallet, String errorMessage) {
    try {
      final amount = parseMoney(value ?? '', wallet.currency);

      return amount.minorUnits > 0 ? null : errorMessage;
    } on FormatException {
      return errorMessage;
    }
  }

  String? _validateExchangeRate(
    String? value,
    Wallet sourceWallet,
    Wallet destinationWallet,
    String errorMessage,
  ) {
    try {
      final rate = ExchangeRate.parse(
        value: value ?? '',
        sourceCurrency: sourceWallet.currency,
        destinationCurrency: destinationWallet.currency,
      );
      final sourceAmount = parseMoney(
        _sourceAmountController.text,
        sourceWallet.currency,
      );

      return rate.convert(sourceAmount).minorUnits > 0 ? null : errorMessage;
    } on Object {
      return errorMessage;
    }
  }

  Money? _calculateDestinationAmount(
    Wallet sourceWallet,
    Wallet destinationWallet,
  ) {
    try {
      final sourceAmount = parseMoney(
        _sourceAmountController.text,
        sourceWallet.currency,
      );
      final rate = ExchangeRate.parse(
        value: _exchangeRateController.text,
        sourceCurrency: sourceWallet.currency,
        destinationCurrency: destinationWallet.currency,
      );
      final destinationAmount = rate.convert(sourceAmount);

      return destinationAmount.minorUnits > 0 ? destinationAmount : null;
    } on Object {
      return null;
    }
  }

  void _synchronizeSuggestedRate({
    required Wallet sourceWallet,
    required Wallet destinationWallet,
    required List<Transfer> transfers,
  }) {
    final pair =
        '${sourceWallet.currency.code}-${destinationWallet.currency.code}';

    if (_ratePair == pair) {
      return;
    }

    final suggestedRate = findLatestExchangeRate(
      transfers: transfers,
      sourceCurrency: sourceWallet.currency,
      destinationCurrency: destinationWallet.currency,
    );
    _ratePair = pair;
    _hasSuggestedRate = suggestedRate != null;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _ratePair != pair) {
        return;
      }

      _isSynchronizingRate = true;
      _exchangeRateController.text = suggestedRate?.toInputValue() ?? '';
      _isSynchronizingRate = false;
      setState(() {});
    });
  }
}

final class _MissingWallets extends StatelessWidget {
  const _MissingWallets({required this.onManageWallets});

  final VoidCallback onManageWallets;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.swap_horiz,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 20),
            Text(
              context.l10n.transferNeedsWallets,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onManageWallets,
              child: Text(context.l10n.manageWallets),
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
