import 'package:customers/customers.dart';
import 'package:customers/application/dtos/customer_dto.dart';

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
  final DateTime createdAt;
  final DateTime updatedAt;

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
  });

  factory CustomerModel.fromDto(CustomerDto dto) {
    return CustomerModel(
      id: dto.id,
      code: dto.code,
      name: dto.name,
      email: dto.email,
      phone: dto.phone,
      address: dto.address,
      creditLimit: dto.creditLimit,
      currentBalance: dto.currentBalance,
      isActive: dto.isActive,
      createdAt: DateTime.parse(dto.createdAt),
      updatedAt: DateTime.parse(dto.updatedAt),
    );
  }

  CustomerDto toDto() {
    return CustomerDto(
      id: id,
      code: code,
      name: name,
      email: email,
      phone: phone,
      address: address,
      creditLimit: creditLimit,
      currentBalance: currentBalance,
      isActive: isActive,
      createdAt: createdAt.toIso8601String(),
      updatedAt: updatedAt.toIso8601String(),
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
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory CustomerModel.fromEntity(Customer entity) {
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
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
