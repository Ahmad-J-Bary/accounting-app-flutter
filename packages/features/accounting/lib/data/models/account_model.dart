import 'package:accounting/accounting.dart';
import 'package:accounting/application/dtos/account_dto.dart';

class AccountModel {
  final String id;
  final String code;
  final String name;
  final String? description;
  final String type;
  final String? parentId;
  final double balance;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  AccountModel({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    required this.type,
    this.parentId,
    required this.balance,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AccountModel.fromDto(AccountDto dto) {
    return AccountModel(
      id: dto.id,
      code: dto.code,
      name: dto.name,
      description: dto.description,
      type: dto.type,
      parentId: dto.parentId,
      balance: dto.balance,
      isActive: dto.isActive,
      createdAt: DateTime.parse(dto.createdAt),
      updatedAt: DateTime.parse(dto.updatedAt),
    );
  }

  AccountDto toDto() {
    return AccountDto(
      id: id,
      code: code,
      name: name,
      description: description,
      type: type,
      parentId: parentId,
      balance: balance,
      isActive: isActive,
      createdAt: createdAt.toIso8601String(),
      updatedAt: updatedAt.toIso8601String(),
    );
  }

  Account toEntity() {
    return Account(
      id: UniqueId.fromUniqueString(id),
      code: code,
      name: name,
      description: description,
      type: AccountType.values.firstWhere(
        (e) => e.name == type,
        orElse: () => AccountType.asset,
      ),
      parentId: parentId != null ? UniqueId.fromUniqueString(parentId!) : null,
      balance: balance,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory AccountModel.fromEntity(Account entity) {
    return AccountModel(
      id: entity.id.value,
      code: entity.code,
      name: entity.name,
      description: entity.description,
      type: entity.type.name,
      parentId: entity.parentId?.value,
      balance: entity.balance,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
