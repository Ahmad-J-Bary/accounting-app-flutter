import 'package:equatable/equatable.dart';
import 'package:shared/shared.dart';

class Supplier extends Equatable {
  final UniqueId id;
  final String code;
  final String name;
  final String? email;
  final String? phone;
  final String? address;
  final String? taxNumber;
  final double creditLimit;
  final double currentBalance;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Supplier({
    required this.id,
    required this.code,
    required this.name,
    this.email,
    this.phone,
    this.address,
    this.taxNumber,
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
        taxNumber,
        creditLimit,
        currentBalance,
        isActive,
        createdAt,
        updatedAt,
      ];
}
