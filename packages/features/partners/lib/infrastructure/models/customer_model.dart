import 'package:partners/partners.dart';
import 'package:foundation/foundation.dart';
import 'dart:convert';

class CustomerModel {
  final String id;
  final String code;
  final String name;
  final String? email;
  final String? phone;
  final String? address;
  final double creditLimit;
  final double currentBalance;
  final bool isActive;
  final String createdAt;
  final String updatedAt;
  final String? taxNumber;

  CustomerModel({
    required this.id,
    required this.code,
    required this.name,
    this.email,
    this.phone,
    this.address,
    required this.creditLimit,
    required this.currentBalance,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.taxNumber,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      creditLimit: (json['creditLimit'] as num).toDouble(),
      currentBalance: (json['currentBalance'] as num).toDouble(),
      isActive: json['isActive'] as bool,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      taxNumber: json['taxNumber'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
      'creditLimit': creditLimit,
      'currentBalance': currentBalance,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      if (taxNumber != null) 'taxNumber': taxNumber,
    };
  }

  static CustomerModel fromEntity(Customer entity) {
    return CustomerModel(
      id: entity.id.value,
      code: entity.code,
      name: entity.name,
      email: entity.email,
      phone: entity.phone,
      address: entity.address,
      creditLimit: entity.creditLimit,
      currentBalance: entity.currentBalance,
      isActive: entity.isActive,
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt.toIso8601String(),
      taxNumber: entity.taxNumber,
    );
  }

  Customer toEntity() {
    return Customer(
      id: UniqueId.fromUniqueString(id),
      code: code,
      name: name,
      email: email,
      phone: phone,
      address: address,
      creditLimit: creditLimit,
      currentBalance: currentBalance,
      isActive: isActive,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
      taxNumber: taxNumber,
    );
  }
}
