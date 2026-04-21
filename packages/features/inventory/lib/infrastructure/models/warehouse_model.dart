import 'package:inventory/inventory.dart';
import 'dart:convert';

class WarehouseModel {
  final String id;
  final String code;
  final String name;
  final String? address;
  final String? phone;
  final String? manager;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  WarehouseModel({
    required this.id,
    required this.code,
    required this.name,
    this.address,
    this.phone,
    this.manager,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WarehouseModel.fromJson(Map<String, dynamic> json) {
    return WarehouseModel(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      manager: json['manager'] as String?,
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
      if (address != null) 'address': address,
      if (phone != null) 'phone': phone,
      if (manager != null) 'manager': manager,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  static WarehouseModel fromEntity(Warehouse entity) {
    return WarehouseModel(
      id: entity.id.value,
      code: entity.code,
      name: entity.name,
      address: entity.address,
      phone: entity.phone,
      manager: entity.manager,
      isActive: entity.isActive,
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt.toIso8601String(),
    );
  }

  Warehouse toEntity() {
    return Warehouse(
      id: UniqueId.fromUniqueString(id),
      code: code,
      name: name,
      address: address,
      phone: phone,
      manager: manager,
      isActive: isActive,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }
}
