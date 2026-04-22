import 'package:products/products.dart';
import 'package:foundation/foundation.dart';
import 'dart:convert';

class ProductModel {
  final String id;
  final String code;
  final String name;
  final String? description;
  final String type;
  final String? categoryId;
  final String? categoryName;
  final double purchasePrice;
  final double salePrice;
  final double cost;
  final String? unit;
  final double taxRate;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  ProductModel({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    required this.type,
    this.categoryId,
    this.categoryName,
    required this.purchasePrice,
    required this.salePrice,
    required this.cost,
    this.unit,
    required this.taxRate,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      type: json['type'] as String,
      categoryId: json['categoryId'] as String?,
      categoryName: json['categoryName'] as String?,
      purchasePrice: (json['purchasePrice'] as num).toDouble(),
      salePrice: (json['salePrice'] as num).toDouble(),
      cost: (json['cost'] as num).toDouble(),
      unit: json['unit'] as String?,
      taxRate: (json['taxRate'] as num).toDouble(),
      isActive: json['isActive'] as bool,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      if (description != null) 'description': description,
      'type': type,
      if (categoryId != null) 'categoryId': categoryId,
      if (categoryName != null) 'categoryName': categoryName,
      'purchasePrice': purchasePrice,
      'salePrice': salePrice,
      'cost': cost,
      if (unit != null) 'unit': unit,
      'taxRate': taxRate,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  static ProductModel fromEntity(Product entity) {
    return ProductModel(
      id: entity.id.value,
      code: entity.code,
      name: entity.name,
      description: entity.description,
      type: entity.type.name,
      categoryId: entity.categoryId?.value,
      categoryName: entity.categoryName,
      purchasePrice: entity.purchasePrice,
      salePrice: entity.salePrice,
      cost: entity.cost,
      unit: entity.unit,
      taxRate: entity.taxRate,
      isActive: entity.isActive,
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt.toIso8601String(),
    );
  }

  Product toEntity() {
    return Product(
      id: UniqueId.fromUniqueString(id),
      code: code,
      name: name,
      description: description,
      type: ProductType.values.firstWhere((e) => e.name == type),
      categoryId: categoryId != null ? UniqueId.fromUniqueString(categoryId!) : null,
      categoryName: categoryName,
      purchasePrice: purchasePrice,
      salePrice: salePrice,
      cost: cost,
      unit: unit,
      taxRate: taxRate,
      isActive: isActive,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }
}
