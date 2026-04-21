import 'package:flutter_test/flutter_test.dart';
import 'package:products/products.dart';

void main() {
  group('Product', () {
    test('should create Product with valid parameters', () {
      final product = Product(
        id: UniqueId(),
        code: 'P001',
        name: 'Widget',
        type: ProductType.inventory,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(product.code, 'P001');
      expect(product.name, 'Widget');
      expect(product.type, ProductType.inventory);
      expect(product.purchasePrice, 0);
      expect(product.salePrice, 0);
      expect(product.cost, 0);
      expect(product.isActive, true);
    });

    test('should create Product with prices', () {
      final product = Product(
        id: UniqueId(),
        code: 'P001',
        name: 'Widget',
        type: ProductType.inventory,
        purchasePrice: 10,
        salePrice: 20,
        cost: 12,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(product.purchasePrice, 10);
      expect(product.salePrice, 20);
      expect(product.cost, 12);
      expect(product.profitMargin, 8);
    });

    test('should calculate profit margin correctly', () {
      final product = Product(
        id: UniqueId(),
        code: 'P001',
        name: 'Widget',
        type: ProductType.inventory,
        salePrice: 25,
        cost: 15,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(product.profitMargin, 10);
    });

    test('should create Product with category', () {
      final categoryId = UniqueId();
      final product = Product(
        id: UniqueId(),
        code: 'P001',
        name: 'Widget',
        type: ProductType.inventory,
        categoryId: categoryId,
        categoryName: 'Electronics',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(product.categoryId, categoryId);
      expect(product.categoryName, 'Electronics');
    });

    test('should create Product with unit and tax rate', () {
      final product = Product(
        id: UniqueId(),
        code: 'P001',
        name: 'Widget',
        type: ProductType.inventory,
        unit: 'PCS',
        taxRate: 0.15,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(product.unit, 'PCS');
      expect(product.taxRate, 0.15);
    });

    test('should support all product types', () {
      for (final type in ProductType.values) {
        final product = Product(
          id: UniqueId(),
          code: 'P001',
          name: 'Test Product',
          type: type,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        expect(product.type, type);
      }
    });
  });
}
