import 'package:inventory/inventory.dart';
import 'package:foundation/foundation.dart';
import 'dart:convert';

class StockMovementModel {
  final String id;
  final String movementNumber;
  final String movementDate;
  final String type;
  final String productId;
  final String productName;
  final String warehouseId;
  final String warehouseName;
  final double quantity;
  final double unitCost;
  final double totalCost;
  final String? reference;
  final String? notes;
  final String createdAt;
  final String updatedAt;

  StockMovementModel({
    required this.id,
    required this.movementNumber,
    required this.movementDate,
    required this.type,
    required this.productId,
    required this.productName,
    required this.warehouseId,
    required this.warehouseName,
    required this.quantity,
    required this.unitCost,
    required this.totalCost,
    this.reference,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StockMovementModel.fromJson(Map<String, dynamic> json) {
    return StockMovementModel(
      id: json['id'] as String,
      movementNumber: json['movementNumber'] as String,
      movementDate: json['movementDate'] as String,
      type: json['type'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      warehouseId: json['warehouseId'] as String,
      warehouseName: json['warehouseName'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unitCost: (json['unitCost'] as num).toDouble(),
      totalCost: (json['totalCost'] as num).toDouble(),
      reference: json['reference'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'movementNumber': movementNumber,
      'movementDate': movementDate,
      'type': type,
      'productId': productId,
      'productName': productName,
      'warehouseId': warehouseId,
      'warehouseName': warehouseName,
      'quantity': quantity,
      'unitCost': unitCost,
      'totalCost': totalCost,
      if (reference != null) 'reference': reference,
      if (notes != null) 'notes': notes,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  static StockMovementModel fromEntity(StockMovement entity) {
    return StockMovementModel(
      id: entity.id.value,
      movementNumber: entity.movementNumber,
      movementDate: entity.movementDate.toIso8601String(),
      type: entity.type.name,
      productId: entity.productId.value,
      productName: entity.productName,
      warehouseId: entity.warehouseId.value,
      warehouseName: entity.warehouseName,
      quantity: entity.quantity,
      unitCost: entity.unitCost,
      totalCost: entity.totalCost,
      reference: entity.reference,
      notes: entity.notes,
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt.toIso8601String(),
    );
  }

  StockMovement toEntity() {
    return StockMovement(
      id: UniqueId.fromUniqueString(id),
      movementNumber: movementNumber,
      movementDate: DateTime.parse(movementDate),
      type: MovementType.values.firstWhere((e) => e.name == type),
      productId: UniqueId.fromUniqueString(productId),
      productName: productName,
      warehouseId: UniqueId.fromUniqueString(warehouseId),
      warehouseName: warehouseName,
      quantity: quantity,
      unitCost: unitCost,
      totalCost: totalCost,
      reference: reference,
      notes: notes,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }
}
