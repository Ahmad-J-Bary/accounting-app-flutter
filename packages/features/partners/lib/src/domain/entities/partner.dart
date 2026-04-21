import 'package:equatable/equatable.dart';
import 'package:foundation/foundation.dart';

enum PartnerType { customer, supplier, owner }

class Partner extends Equatable {
  final UniqueId id;
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

  const Partner({
    required this.id,
    required this.code,
    required this.name,
    this.email,
    this.phone,
    this.address,
    this.creditLimit = 0,
    this.currentBalance = 0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isCustomer => true; // Will be overridden by Customer
  bool get isSupplier => true; // Will be overridden by Supplier
  bool get isOwner => true; // Will be overridden by Owner

  Partner copyWith({
    UniqueId? id,
    String? code,
    String? name,
    String? email,
    String? phone,
    String? address,
    double? creditLimit,
    double? currentBalance,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Partner(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      creditLimit: creditLimit ?? this.creditLimit,
      currentBalance: currentBalance ?? this.currentBalance,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        code,
        name,
        email,
        phone,
        address,
        creditLimit,
        currentBalance,
        isActive,
        createdAt,
        updatedAt,
      ];
}
