import 'package:chuspita/features/transfers/domain/transfer_id.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TransferId', () {
    test('normalizes its value', () {
      final id = TransferId(' transfer-1 ');

      expect(id.value, 'transfer-1');
    });

    test('rejects an empty value', () {
      expect(() => TransferId('   '), throwsArgumentError);
    });

    test('uses value equality', () {
      final first = TransferId('transfer-1');
      final second = TransferId('transfer-1');

      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });
  });
}
