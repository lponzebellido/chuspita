final class Currency {
  const Currency._({required this.code, required this.minorUnitDigits});

  static const eur = Currency._(code: 'EUR', minorUnitDigits: 2);
  static const pen = Currency._(code: 'PEN', minorUnitDigits: 2);
  static const usd = Currency._(code: 'USD', minorUnitDigits: 2);
  static const pln = Currency._(code: 'PLN', minorUnitDigits: 2);
  static const brl = Currency._(code: 'BRL', minorUnitDigits: 2);
  static const clp = Currency._(code: 'CLP', minorUnitDigits: 0);
  static const gbp = Currency._(code: 'GBP', minorUnitDigits: 2);
  static const chf = Currency._(code: 'CHF', minorUnitDigits: 2);
  static const jpy = Currency._(code: 'JPY', minorUnitDigits: 0);
  static const kwd = Currency._(code: 'KWD', minorUnitDigits: 3);

  static const supported = <Currency>[
    eur,
    pen,
    usd,
    pln,
    brl,
    clp,
    gbp,
    chf,
    jpy,
    kwd,
  ];

  static const _byCode = <String, Currency>{
    'EUR': eur,
    'PEN': pen,
    'USD': usd,
    'PLN': pln,
    'BRL': brl,
    'CLP': clp,
    'GBP': gbp,
    'CHF': chf,
    'JPY': jpy,
    'KWD': kwd,
  };

  final String code;
  final int minorUnitDigits;

  static Currency fromCode(String code) {
    final normalizedCode = code.trim().toUpperCase();
    final currency = _byCode[normalizedCode];

    if (currency == null) {
      throw ArgumentError.value(
        code,
        'code',
        'Unsupported ISO 4217 currency code',
      );
    }

    return currency;
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Currency &&
            code == other.code &&
            minorUnitDigits == other.minorUnitDigits;
  }

  @override
  int get hashCode => Object.hash(code, minorUnitDigits);
}
