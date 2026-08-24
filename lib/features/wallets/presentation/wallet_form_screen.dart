import 'package:chuspita/app/formatters/money_formatter.dart';
import 'package:chuspita/app/providers.dart';
import 'package:chuspita/core/currency/currency.dart';
import 'package:chuspita/core/money/parse_money.dart';
import 'package:chuspita/features/wallets/domain/wallet.dart';
import 'package:chuspita/features/wallets/domain/wallet_currency_change_not_allowed.dart';
import 'package:chuspita/l10n/app_localizations_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class WalletFormScreen extends ConsumerStatefulWidget {
  const WalletFormScreen({super.key, this.wallet});

  final Wallet? wallet;

  @override
  ConsumerState<WalletFormScreen> createState() => _WalletFormScreenState();
}

final class _WalletFormScreenState extends ConsumerState<WalletFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _initialBalanceController;
  late Currency _currency;
  bool _isSaving = false;
  String? _saveError;

  @override
  void initState() {
    super.initState();
    final wallet = widget.wallet;
    _nameController = TextEditingController(text: wallet?.name);
    _initialBalanceController = TextEditingController(
      text: wallet == null
          ? '0'
          : formatMoneyAmount(wallet.initialBalance, localeName: 'en'),
    );
    _currency = wallet?.currency ?? Currency.eur;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _initialBalanceController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
      _saveError = null;
    });

    try {
      final initialBalance = parseMoney(
        _initialBalanceController.text,
        _currency,
      );
      final wallet = widget.wallet;

      if (wallet == null) {
        await ref
            .read(createWalletProvider)
            .call(name: _nameController.text, initialBalance: initialBalance);
      } else {
        await ref
            .read(updateWalletProvider)
            .details(
              wallet: wallet,
              name: _nameController.text,
              initialBalance: initialBalance,
            );
      }

      ref.invalidate(walletsProvider);
      ref.invalidate(balanceSummaryProvider);

      if (mounted) {
        Navigator.of(context).pop();
      }
    } on WalletCurrencyChangeNotAllowed {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _saveError = context.l10n.walletCurrencyChangeNotAllowed;
        });
      }
    } on Object {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _saveError = context.l10n.saveWalletError;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isEditing = widget.wallet != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? l10n.editWalletTitle : l10n.newWalletTitle),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          children: [
            TextFormField(
              controller: _nameController,
              autofocus: !isEditing,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: l10n.walletNameLabel,
                hintText: l10n.walletNameHint,
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.walletNameRequired;
                }

                return null;
              },
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<Currency>(
              initialValue: _currency,
              decoration: InputDecoration(
                labelText: l10n.currencyLabel,
                border: const OutlineInputBorder(),
              ),
              items: [
                for (final currency in Currency.supported)
                  DropdownMenuItem(value: currency, child: Text(currency.code)),
              ],
              onChanged: _isSaving
                  ? null
                  : (currency) {
                      if (currency != null) {
                        setState(() => _currency = currency);
                      }
                    },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _initialBalanceController,
              enabled: !_isSaving,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              decoration: InputDecoration(
                labelText: l10n.initialBalanceLabel,
                suffixText: _currency.code,
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                try {
                  parseMoney(value ?? '', _currency);
                  return null;
                } on FormatException {
                  return l10n.initialBalanceInvalid;
                }
              },
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
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: FilledButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.save),
        ),
      ),
    );
  }
}
