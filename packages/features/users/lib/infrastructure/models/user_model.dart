import 'package:users/users.dart';
import 'dart:convert';

class UserModel {
  final String id;
  final String username;
  final String email;
  final String fullName;
  final String? phone;
  final String role;
  final bool isActive;
  final String createdAt;
  final String updatedAt;
  final String? passwordHash;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    this.phone,
    required this.role,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.passwordHash,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      phone: json['phone'] as String?,
      role: json['role'] as String,
      isActive: json['isActive'] as bool,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      passwordHash: json['passwordHash'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'fullName': fullName,
      'phone': phone,
      'role': role,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      if (passwordHash != null) 'passwordHash': passwordHash,
    };
  }

  static UserModel fromEntity(User entity) {
    return UserModel(
      id: entity.id.value,
      username: entity.username,
      email: entity.email,
      fullName: entity.fullName,
      phone: entity.phone,
      role: entity.role.name,
      isActive: entity.isActive,
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt.toIso8601String(),
    );
  }

  User toEntity() {
    return User(
      id: UniqueId.fromUniqueString(id),
      username: username,
      email: email,
      fullName: fullName,
      phone: phone,
      role: UserRole.values.firstWhere((e) => e.name == role),
      isActive: isActive,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }
}
