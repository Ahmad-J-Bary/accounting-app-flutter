import 'package:assets/assets.dart';
import 'package:foundation/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ConsumableItem', () {
    final currency = Currency.syp();
    
    test('should create ConsumableItem correctly', () {
      final item = ConsumableItem(
        id: UniqueId.generate(),
        code: 'CON-001',
        name: 'تعبئة',
        categoryId: UniqueId.generate(),
        quantityOnHand: Quantity(100, 'piece'),
        unitOfMeasure: Quantity(1, 'piece'),
        unitCost: Money.fromDouble(50, currency),
        currency: currency,
        fxRate: MoneyFxRate(
          fromCurrency: currency,
          toCurrency: currency,
          rate: 1,
          rateDate: DateTime.now(),
        ),
        totalCost: Money.fromDouble(5000, currency),
        status: ConsumableStatus.inStock,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(item.code, 'CON-001');
      expect(item.name, 'تعبئة');
      expect(item.quantityOnHand.value, 100);
      expect(item.status, ConsumableStatus.inStock);
    });

    test('should check stock availability correctly', () {
      final item = ConsumableItem(
        id: UniqueId.generate(),
        code: 'CON-001',
        name: 'تعبئة',
        categoryId: UniqueId.generate(),
        quantityOnHand: Quantity(100, 'piece'),
        unitOfMeasure: Quantity(1, 'piece'),
        unitCost: Money.fromDouble(50, currency),
        currency: currency,
        fxRate: MoneyFxRate(
          fromCurrency: currency,
          toCurrency: currency,
          rate: 1,
          rateDate: DateTime.now(),
        ),
        totalCost: Money.fromDouble(5000, currency),
        status: ConsumableStatus.inStock,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(item.hasSufficientStock(Quantity(50, 'piece')), true);
      expect(item.hasSufficientStock(Quantity(100, 'piece')), true);
      expect(item.hasSufficientStock(Quantity(101, 'piece')), false);
    });

    test('should issue quantity correctly', () {
      final item = ConsumableItem(
        id: UniqueId.generate(),
        code: 'CON-001',
        name: 'تعبئة',
        categoryId: UniqueId.generate(),
        quantityOnHand: Quantity(100, 'piece'),
        unitOfMeasure: Quantity(1, 'piece'),
        unitCost: Money.fromDouble(50, currency),
        currency: currency,
        fxRate: MoneyFxRate(
          fromCurrency: currency,
          toCurrency: currency,
          rate: 1,
          rateDate: DateTime.now(),
        ),
        totalCost: Money.fromDouble(5000, currency),
        status: ConsumableStatus.inStock,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final updated = item.issue(Quantity(30, 'piece'));

      expect(updated.quantityOnHand.value, 70);
      expect(updated.totalCost.amount, 3500); // 70 * 50
    });

    test('should throw exception when issuing more than available', () {
      final item = ConsumableItem(
        id: UniqueId.generate(),
        code: 'CON-001',
        name: 'تعبئة',
        categoryId: UniqueId.generate(),
        quantityOnHand: Quantity(100, 'piece'),
        unitOfMeasure: Quantity(1, 'piece'),
        unitCost: Money.fromDouble(50, currency),
        currency: currency,
        fxRate: MoneyFxRate(
          fromCurrency: currency,
          toCurrency: currency,
          rate: 1,
          rateDate: DateTime.now(),
        ),
        totalCost: Money.fromDouble(5000, currency),
        status: ConsumableStatus.inStock,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(
        () => item.issue(Quantity(101, 'piece')),
        throwsA(isA<InsufficientConsumableStockFailure>()),
      );
    });

    test('should receive quantity with weighted average cost', () {
      final item = ConsumableItem(
        id: UniqueId.generate(),
        code: 'CON-001',
        name: 'تعبئة',
        categoryId: UniqueId.generate(),
        quantityOnHand: Quantity(100, 'piece'),
        unitOfMeasure: Quantity(1, 'piece'),
        unitCost: Money.fromDouble(50, currency),
        currency: currency,
        fxRate: MoneyFxRate(
          fromCurrency: currency,
          toCurrency: currency,
          rate: 1,
          rateDate: DateTime.now(),
        ),
        totalCost: Money.fromDouble(5000, currency),
        status: ConsumableStatus.inStock,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Receive 50 more at 60 per unit
      final updated = item.receive(Quantity(50, 'piece'), Money.fromDouble(60, currency));

      // New total: 150 pieces
      // New average cost: (100*50 + 50*60) / 150 = 53.33
      expect(updated.quantityOnHand.value, 150);
      expect(updated.totalCost.amount, closeTo(8000, 0.01));
    });

    test('should calculate consumption cost correctly', () {
      final item = ConsumableItem(
        id: UniqueId.generate(),
        code: 'CON-001',
        name: 'تعبئة',
        categoryId: UniqueId.generate(),
        quantityOnHand: Quantity(100, 'piece'),
        unitOfMeasure: Quantity(1, 'piece'),
        unitCost: Money.fromDouble(50, currency),
        currency: currency,
        fxRate: MoneyFxRate(
          fromCurrency: currency,
          toCurrency: currency,
          rate: 1,
          rateDate: DateTime.now(),
        ),
        totalCost: Money.fromDouble(5000, currency),
        status: ConsumableStatus.inStock,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final consumptionCost = ConsumablePolicy.calculateConsumptionCost(
        item,
        Quantity(20, 'piece'),
      );

      expect(consumptionCost.amount, 1000); // 20 * 50
    });
  });
}
