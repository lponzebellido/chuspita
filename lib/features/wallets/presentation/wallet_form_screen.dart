import 'package:chuspita/app/providers.dart';
import 'package:chuspita/core/color/argb_color.dart';
import 'package:chuspita/core/currency/currency.dart';
import 'package:chuspita/core/money/parse_money.dart';
import 'package:chuspita/l10n/app_localizations_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class WalletFormScreen extends ConsumerStatefulWidget {
  const WalletFormScreen({super.key});

  @override
  ConsumerState<WalletFormScreen> createState() => _WalletFormScreenState();
}

final class _WalletFormScreenState extends ConsumerState<WalletFormScreen> {
  static const _colors = <int>[
    0xFF5B5BD6,
    0xFF2E7D32,
    0xFF00838F,
    0xFFF57C00,
    0xFFC62828,
    0xFF6A1B9A,
  ];

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _initialBalanceController = TextEditingController(text: '0');
  Currency _currency = Currency.eur;
  int _colorValue = _colors.first;
  bool _isSaving = false;
  String? _saveError;

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
      await ref
          .read(createWalletProvider)
          .call(
            name: _nameController.text,
            initialBalance: parseMoney(
              _initialBalanceController.text,
              _currency,
            ),
            color: ArgbColor(_colorValue),
          );
      ref.invalidate(balanceSummaryProvider);

      if (mounted) {
        Navigator.of(context).pop();
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

    return Scaffold(
      appBar: AppBar(title: Text(l10n.newWalletTitle)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          children: [
            TextFormField(
              controller: _nameController,
              autofocus: true,
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
            const SizedBox(height: 24),
            Text(
              l10n.walletColorLabel,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final color in _colors)
                  _ColorOption(
                    color: color,
                    isSelected: color == _colorValue,
                    onSelected: _isSaving
                        ? null
                        : () => setState(() => _colorValue = color),
                  ),
              ],
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

final class _ColorOption extends StatelessWidget {
  const _ColorOption({
    required this.color,
    required this.isSelected,
    required this.onSelected,
  });

  final int color;
  final bool isSelected;
  final VoidCallback? onSelected;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      child: InkWell(
        key: ValueKey('wallet-color-$color'),
        customBorder: const CircleBorder(),
        onTap: onSelected,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color(color),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.onSurface
                  : Colors.transparent,
              width: 3,
            ),
          ),
          child: isSelected
              ? const Icon(Icons.check, color: Colors.white)
              : null,
        ),
      ),
    );
  }
}
