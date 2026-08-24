import 'package:drift/drift.dart';

@DataClassName('WalletRow')
class Wallets extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get currencyCode => text()();
  IntColumn get initialBalanceMinor => integer()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  IntColumn get createdAtMillis => integer()();
  IntColumn get updatedAtMillis => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK (length(trim(name)) > 0)',
    "CHECK (currency_code GLOB '[A-Z][A-Z][A-Z]')",
    'CHECK (is_archived IN (0, 1))',
    'CHECK (created_at_millis > 0)',
    'CHECK (updated_at_millis >= created_at_millis)',
  ];
}

@DataClassName('CategoryRow')
class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get colorArgb => integer()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  IntColumn get createdAtMillis => integer()();
  IntColumn get updatedAtMillis => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK (length(trim(name)) > 0)',
    'CHECK (color_argb BETWEEN 0 AND 4294967295)',
    'CHECK (is_archived IN (0, 1))',
    'CHECK (created_at_millis > 0)',
    'CHECK (updated_at_millis >= created_at_millis)',
  ];
}

@DataClassName('TransactionRow')
@TableIndex(
  name: 'transactions_wallet_date_idx',
  columns: {#walletId, #occurredOn},
)
@TableIndex(
  name: 'transactions_category_date_idx',
  columns: {#categoryId, #occurredOn},
)
class Transactions extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()();
  IntColumn get amountMinor => integer()();

  TextColumn get walletId =>
      text().references(Wallets, #id, onDelete: KeyAction.restrict)();

  TextColumn get categoryId =>
      text().references(Categories, #id, onDelete: KeyAction.restrict)();

  TextColumn get occurredOn => text()();
  TextColumn get note => text().nullable()();
  IntColumn get createdAtMillis => integer()();
  IntColumn get updatedAtMillis => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    "CHECK (type IN ('income', 'expense'))",
    'CHECK (amount_minor > 0)',
    "CHECK (occurred_on GLOB "
        "'[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]')",
    'CHECK (created_at_millis > 0)',
    'CHECK (updated_at_millis >= created_at_millis)',
  ];
}

@DataClassName('TransferRow')
@TableIndex(
  name: 'transfers_source_wallet_date_idx',
  columns: {#sourceWalletId, #occurredOn},
)
@TableIndex(
  name: 'transfers_destination_wallet_date_idx',
  columns: {#destinationWalletId, #occurredOn},
)
class Transfers extends Table {
  TextColumn get id => text()();

  @ReferenceName('outgoingTransfers')
  TextColumn get sourceWalletId =>
      text().references(Wallets, #id, onDelete: KeyAction.restrict)();

  @ReferenceName('incomingTransfers')
  TextColumn get destinationWalletId =>
      text().references(Wallets, #id, onDelete: KeyAction.restrict)();

  IntColumn get sourceAmountMinor => integer()();
  IntColumn get destinationAmountMinor => integer()();
  TextColumn get occurredOn => text()();
  TextColumn get note => text().nullable()();
  IntColumn get createdAtMillis => integer()();
  IntColumn get updatedAtMillis => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK (source_wallet_id != destination_wallet_id)',
    'CHECK (source_amount_minor > 0)',
    'CHECK (destination_amount_minor > 0)',
    "CHECK (occurred_on GLOB "
        "'[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]')",
    'CHECK (created_at_millis > 0)',
    'CHECK (updated_at_millis >= created_at_millis)',
  ];
}
