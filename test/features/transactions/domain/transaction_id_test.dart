import 'package:chuspita/features/transactions/domain/transaction_id.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TransactionId', () {
    test('normalizes its value', () {
      final id = TransactionId(' transaction-1 ');

      expect(id.value, 'transaction-1');
    });

    test('rejects an empty value', () {
      expect(() => TransactionId('   '), throwsArgumentError);
    });

    test('uses value equality', () {
      final first = TransactionId('transaction-1');
      final second = TransactionId('transaction-1');

      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });
  });
}
