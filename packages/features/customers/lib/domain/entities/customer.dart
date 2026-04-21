import 'package:equatable/equatable.dart';
import 'package:shared/shared.dart';

class Customer extends Equatable {
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

  const Customer({
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
