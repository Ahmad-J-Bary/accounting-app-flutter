import 'package:equatable/equatable.dart';
import 'package:shared/shared.dart';

enum AccountType {
  asset,
  liability,
  equity,
  revenue,
  expense,
}

class Account extends Equatable {
  final UniqueId id;
  final String code;
  final String name;
  final String? description;
  final AccountType type;
  final UniqueId? parentId;
  final double balance;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Account({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    required this.type,
    this.parentId,
    this.balance = 0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        code,
        name,
        description,
        type,
        parentId,
        balance,
        isActive,
        createdAt,
        updatedAt,
      ];
}
