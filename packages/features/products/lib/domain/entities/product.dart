import 'package:equatable/equatable.dart';
import 'package:foundation/foundation.dart';

enum ProductType {
  inventory,
  service,
  nonInventory,
}

class Product extends Equatable {
  final UniqueId id;
  final String code;
  final String name;
  final String? description;
  final ProductType type;
  final UniqueId? categoryId;
  final String? categoryName;
  final double purchasePrice;
  final double salePrice;
  final double cost;
  final String? unit;
  final double taxRate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Product({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    required this.type,
    this.categoryId,
    this.categoryName,
    this.purchasePrice = 0,
    this.salePrice = 0,
    this.cost = 0,
    this.unit,
    this.taxRate = 0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  double get profitMargin => salePrice - cost;

  @override
  List<Object?> get props => [
        id,
        code,
        name,
        description,
        type,
        categoryId,
        categoryName,
        purchasePrice,
        salePrice,
        cost,
        unit,
        taxRate,
        isActive,
        createdAt,
        updatedAt,
      ];
}
