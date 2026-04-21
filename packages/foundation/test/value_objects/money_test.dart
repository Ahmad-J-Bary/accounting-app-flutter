import 'package:flutter_test/flutter_test.dart';
import 'package:shared/shared.dart';

void main() {
  group('Money', () {
    test('should create Money with valid value', () {
      const money = Money(100);
      expect(money.value, 100);
    });

    test('should create zero Money', () {
      const money = Money.zero();
      expect(money.value, 0);
      expect(money.isZero, true);
    });

    test('should add Money correctly', () {
      const money1 = Money(100);
      const money2 = Money(50);
      final result = money1.add(money2);
      expect(result.value, 150);
    });

    test('should subtract Money correctly', () {
      const money1 = Money(100);
      const money2 = Money(50);
      final result = money1.subtract(money2);
      expect(result.value, 50);
    });

    test('should multiply Money correctly', () {
      const money = Money(100);
      final result = money.multiply(2);
      expect(result.value, 200);
    });

    test('should identify positive Money', () {
      const money = Money(100);
      expect(money.isPositive, true);
      expect(money.isZero, false);
    });

    test('should format to string correctly', () {
      const money = Money(100.5);
      expect(money.toString(), '100.50');
    });

    test('should throw assertion for negative value', () {
      expect(() => const Money(-10), throwsAssertionError);
    });
  });
}
