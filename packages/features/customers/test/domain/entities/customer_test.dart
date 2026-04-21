import 'package:flutter_test/flutter_test.dart';
import 'package:customers/customers.dart';

void main() {
  group('Customer', () {
    test('should create Customer with valid parameters', () {
      final customer = Customer(
        id: UniqueId(),
        code: 'C001',
        name: 'John Doe',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(customer.code, 'C001');
      expect(customer.name, 'John Doe');
      expect(customer.creditLimit, 0);
      expect(customer.currentBalance, 0);
      expect(customer.isActive, true);
    });

    test('should create Customer with contact details', () {
      final customer = Customer(
        id: UniqueId(),
        code: 'C001',
        name: 'John Doe',
        email: 'john@example.com',
        phone: '+1234567890',
        address: '123 Main St',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(customer.email, 'john@example.com');
      expect(customer.phone, '+1234567890');
      expect(customer.address, '123 Main St');
    });

    test('should create Customer with credit limit', () {
      final customer = Customer(
        id: UniqueId(),
        code: 'C001',
        name: 'John Doe',
        creditLimit: 5000,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(customer.creditLimit, 5000);
    });

    test('should create Customer with current balance', () {
      final customer = Customer(
        id: UniqueId(),
        code: 'C001',
        name: 'John Doe',
        currentBalance: 1000,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(customer.currentBalance, 1000);
    });

    test('should create inactive Customer', () {
      final customer = Customer(
        id: UniqueId(),
        code: 'C001',
        name: 'John Doe',
        isActive: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(customer.isActive, false);
    });
  });
}
