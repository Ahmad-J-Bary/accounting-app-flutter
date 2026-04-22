import 'package:foundation/foundation.dart';
import '../../../domain/domain.dart';

/// نموذج تصنيف الأصول للتخزين في قاعدة البيانات
class AssetCategoryModel {
  final String id;
  final String code;
  final String name;
  final String type; // 'fixed' or 'consumable'
  final String? description;
  final int isActive; // 1 = true, 0 = false
  final String createdAt;
  final String updatedAt;

  const AssetCategoryModel({
    required this.id,
    required this.code,
    required this.name,
    required this.type,
    this.description,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AssetCategoryModel.fromJson(Map<String, dynamic> json) {
    return AssetCategoryModel(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      description: json['description'] as String?,
      isActive: json['isActive'] as int,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'type': type,
      'description': description,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// تحويل من كيان المجال إلى نموذج
  factory AssetCategoryModel.fromEntity(AssetCategory entity) {
    return AssetCategoryModel(
      id: entity.id.value,
      code: entity.code,
      name: entity.name,
      type: entity.type.englishName,
      description: entity.description,
      isActive: entity.isActive ? 1 : 0,
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt.toIso8601String(),
    );
  }

  /// تحويل النموذج إلى كيان المجال
  AssetCategory toEntity() {
    return AssetCategory(
      id: UniqueId.fromUniqueString(id),
      code: code,
      name: name,
      type: _parseType(type),
      description: description,
      isActive: isActive == 1,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }

  AssetType _parseType(String type) {
    switch (type.toLowerCase()) {
      case 'fixed':
        return AssetType.fixed;
      case 'consumable':
        return AssetType.consumable;
      default:
        return AssetType.fixed;
    }
  }
}
