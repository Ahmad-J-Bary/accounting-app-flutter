import 'package:equatable/equatable.dart';
import 'package:foundation/foundation.dart';

/// تصنيف الأصول (للموجودات الثابتة والمستهلكة)
class AssetCategory extends Equatable {
  final UniqueId id;
  final String code;
  final String name;
  final AssetType type;
  final String? description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AssetCategory({
    required this.id,
    required this.code,
    required this.name,
    required this.type,
    this.description,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  AssetCategory copyWith({
    String? name,
    AssetType? type,
    String? description,
    bool? isActive,
    DateTime? updatedAt,
  }) {
    return AssetCategory(
      id: id,
      code: code,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, code, name, type, isActive];
}

/// نوع الأصل
enum AssetType {
  fixed,
  consumable,
}

extension AssetTypeExtension on AssetType {
  String get displayName {
    switch (this) {
      case AssetType.fixed:
        return 'موجود ثابت';
      case AssetType.consumable:
        return 'مستهلكات';
    }
  }

  String get englishName {
    switch (this) {
      case AssetType.fixed:
        return 'fixed';
      case AssetType.consumable:
        return 'consumable';
    }
  }
}
