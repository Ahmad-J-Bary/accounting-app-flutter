import 'package:flutter_test/flutter_test.dart';
import 'package:shared/shared.dart';

void main() {
  group('Quantity', () {
    test('should create Quantity with valid value', () {
      const quantity = Quantity(10);
      expect(quantity.value, 10);
    });

    test('should create zero Quantity', () {
      const quantity = Quantity.zero();
      expect(quantity.value, 0);
      expect(quantity.isZero, true);
    });

    test('should add Quantity correctly', () {
      const quantity1 = Quantity(10);
      const quantity2 = Quantity(5);
      final result = quantity1.add(quantity2);
      expect(result.value, 15);
    });

    test('should subtract Quantity correctly', () {
      const quantity1 = Quantity(10);
      const quantity2 = Quantity(5);
      final result = quantity1.subtract(quantity2);
      expect(result.value, 5);
    });

    test('should identify positive Quantity', () {
      const quantity = Quantity(10);
      expect(quantity.isPositive, true);
      expect(quantity.isZero, false);
    });

    test('should format to string correctly', () {
      const quantity = Quantity(10.5);
      expect(quantity.toString(), '10.500');
    });

    test('should throw assertion for negative value', () {
      expect(() => const Quantity(-10), throwsAssertionError);
    });
  });
}
