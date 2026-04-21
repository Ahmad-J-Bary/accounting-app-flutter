import 'package:flutter_test/flutter_test.dart';
import 'package:accounting/accounting.dart';

void main() {
  group('Account', () {
    test('should create Account with valid parameters', () {
      final account = Account(
        id: UniqueId(),
        code: '1000',
        name: 'Cash',
        type: AccountType.asset,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(account.code, '1000');
      expect(account.name, 'Cash');
      expect(account.type, AccountType.asset);
      expect(account.balance, 0);
      expect(account.isActive, true);
    });

    test('should create Account with parent', () {
      final parentId = UniqueId();
      final account = Account(
        id: UniqueId(),
        code: '1001',
        name: 'Bank Account',
        type: AccountType.asset,
        parentId: parentId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(account.parentId, parentId);
    });

    test('should create Account with balance', () {
      final account = Account(
        id: UniqueId(),
        code: '1000',
        name: 'Cash',
        type: AccountType.asset,
        balance: 1000,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(account.balance, 1000);
    });

    test('should create inactive Account', () {
      final account = Account(
        id: UniqueId(),
        code: '1000',
        name: 'Cash',
        type: AccountType.asset,
        isActive: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(account.isActive, false);
    });

    test('should support all account types', () {
      for (final type in AccountType.values) {
        final account = Account(
          id: UniqueId(),
          code: '1000',
          name: 'Test Account',
          type: type,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        expect(account.type, type);
      }
    });
  });
}
