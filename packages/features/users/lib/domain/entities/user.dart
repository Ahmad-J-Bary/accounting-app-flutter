import 'package:equatable/equatable.dart';
import 'package:foundation/foundation.dart';

enum UserRole { admin, cashier, warehouse, accountant, viewer }

class User extends Equatable {
  final UniqueId id;
  final String username;
  final String email;
  final String fullName;
  final String? phone;
  final UserRole role;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    this.phone,
    required this.role,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isAdmin => role == UserRole.admin;
  bool get canManageUsers => role == UserRole.admin;
  bool get canManageProducts => role == UserRole.admin || role == UserRole.warehouse;
  bool get canManageSales => role == UserRole.admin || role == UserRole.cashier;
  bool get canManageAccounting => role == UserRole.admin || role == UserRole.accountant;

  User copyWith({
    UniqueId? id,
    String? username,
    String? email,
    String? fullName,
    String? phone,
    UserRole? role,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        username,
        email,
        fullName,
        phone,
        role,
        isActive,
        createdAt,
        updatedAt,
      ];
}
