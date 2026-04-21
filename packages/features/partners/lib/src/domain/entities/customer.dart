import 'package:foundation/foundation.dart';
import 'partner.dart';

class Customer extends Partner {
  final String? taxNumber;

  const Customer({
    required UniqueId id,
    required String code,
    required String name,
    String? email,
    String? phone,
    String? address,
    double creditLimit = 0,
    double currentBalance = 0,
    bool isActive = true,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.taxNumber,
  }) : super(
          id: id,
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

  @override
  bool get isCustomer => true;
  @override
  bool get isSupplier => false;
  @override
  bool get isOwner => false;

  Customer copyWith({
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
    String? taxNumber,
  }) {
    return Customer(
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
      taxNumber: taxNumber ?? this.taxNumber,
    );
  }
}
