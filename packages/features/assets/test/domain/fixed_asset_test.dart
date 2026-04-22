import 'package:assets/assets.dart';
import 'package:foundation/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FixedAsset', () {
    final currency = Currency.syp();
    
    test('should create FixedAsset correctly', () {
      final asset = FixedAsset(
        id: UniqueId.generate(),
        code: 'FA-001',
        name: 'جرة غاز',
        categoryId: UniqueId.generate(),
        purchaseDate: DateTime.now(),
        purchaseCost: Money.fromDouble(5000, currency),
        currency: currency,
        fxRate: MoneyFxRate(
          fromCurrency: currency,
          toCurrency: currency,
          rate: 1,
          rateDate: DateTime.now(),
        ),
        usefulLifeMonths: 24,
        accumulatedDepreciation: Money.zero(currency),
        netBookValue: Money.fromDouble(5000, currency),
        status: AssetStatus.active,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(asset.code, 'FA-001');
      expect(asset.name, 'جرة غاز');
      expect(asset.usefulLifeMonths, 24);
      expect(asset.status, AssetStatus.active);
    });

    test('should calculate monthly depreciation correctly', () {
      final asset = FixedAsset(
        id: UniqueId.generate(),
        code: 'FA-001',
        name: 'جرة غاز',
        categoryId: UniqueId.generate(),
        purchaseDate: DateTime.now(),
        purchaseCost: Money.fromDouble(12000, currency),
        currency: currency,
        fxRate: MoneyFxRate(
          fromCurrency: currency,
          toCurrency: currency,
          rate: 1,
          rateDate: DateTime.now(),
        ),
        usefulLifeMonths: 12,
        salvageValue: Money.fromDouble(2000, currency),
        accumulatedDepreciation: Money.zero(currency),
        netBookValue: Money.fromDouble(12000, currency),
        status: AssetStatus.active,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // (12000 - 2000) / 12 = 833.33
      expect(asset.monthlyDepreciation.amount, closeTo(833.33, 0.01));
    });

    test('should determine isDepreciable correctly', () {
      final activeAsset = FixedAsset(
        id: UniqueId.generate(),
        code: 'FA-001',
        name: 'أصل نشط',
        categoryId: UniqueId.generate(),
        purchaseDate: DateTime.now(),
        purchaseCost: Money.fromDouble(5000, currency),
        currency: currency,
        fxRate: MoneyFxRate(
          fromCurrency: currency,
          toCurrency: currency,
          rate: 1,
          rateDate: DateTime.now(),
        ),
        usefulLifeMonths: 12,
        accumulatedDepreciation: Money.zero(currency),
        netBookValue: Money.fromDouble(5000, currency),
        status: AssetStatus.active,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(activeAsset.isDepreciable, true);
    });

    test('should create copy with updated values', () {
      final asset = FixedAsset(
        id: UniqueId.generate(),
        code: 'FA-001',
        name: 'جرة غاز',
        categoryId: UniqueId.generate(),
        purchaseDate: DateTime.now(),
        purchaseCost: Money.fromDouble(5000, currency),
        currency: currency,
        fxRate: MoneyFxRate(
          fromCurrency: currency,
          toCurrency: currency,
          rate: 1,
          rateDate: DateTime.now(),
        ),
        usefulLifeMonths: 12,
        accumulatedDepreciation: Money.zero(currency),
        netBookValue: Money.fromDouble(5000, currency),
        status: AssetStatus.active,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final updated = asset.copyWith(
        name: 'جرة غاز جديدة',
        location: 'المستودع',
      );

      expect(updated.name, 'جرة غاز جديدة');
      expect(updated.location, 'المستودع');
      expect(updated.code, asset.code); // unchanged
    });
  });
}
