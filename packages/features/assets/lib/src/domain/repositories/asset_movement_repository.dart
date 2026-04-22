import 'package:dartz/dartz.dart';
import 'package:foundation/foundation.dart';
import '../entities/asset_entities.dart';
import '../failures/asset_failures.dart';

/// واجهة مستودع حركات الأصول
abstract class AssetMovementRepository {
  /// الحصول على حركة بواسطة المعرف
  Future<Either<AssetFailure, AssetMovement>> getById(UniqueId id);
  
  /// الحصول على حركات أصل معين
  Future<Either<AssetFailure, List<AssetMovement>>> getByAssetId(
    UniqueId assetId, {
    AssetType? type,
    AssetMovementType? movementType,
    DateTime? fromDate,
    DateTime? toDate,
  });
  
  /// الحصول على جميع الحركات
  Future<Either<AssetFailure, List<AssetMovement>>> getAll({
    AssetType? assetType,
    AssetMovementType? movementType,
    DateTime? fromDate,
    DateTime? toDate,
    String? referenceNo,
    bool? isPosted,
    int? limit,
    int? offset,
  });
  
  /// إنشاء حركة جديدة
  Future<Either<AssetFailure, AssetMovement>> create(AssetMovement movement);
  
  /// تحديث حركة
  Future<Either<AssetFailure, AssetMovement>> update(AssetMovement movement);
  
  /// حذف حركة
  Future<Either<AssetFailure, Unit>> delete(UniqueId id);
  
  /// ترحيل الحركة (ربطها بقيد محاسبي)
  Future<Either<AssetFailure, AssetMovement>> post(
    UniqueId movementId,
    UniqueId journalEntryId,
  );
  
  /// عكس الترحيل
  Future<Either<AssetFailure, AssetMovement>> reverse(UniqueId movementId);
  
  /// الحصول على ملخص الحركات
  Future<Either<AssetFailure, AssetMovementsSummary>> getSummary({
    DateTime? fromDate,
    DateTime? toDate,
  });
}

/// ملخص حركات الأصول
class AssetMovementsSummary {
  final int totalMovements;
  final int postedMovements;
  final int unpostedMovements;
  final Map<AssetMovementType, int> countByType;
  final Map<AssetMovementType, Money> valueByType;
  final Money totalInflow;
  final Money totalOutflow;
  final Money netMovement;

  const AssetMovementsSummary({
    required this.totalMovements,
    required this.postedMovements,
    required this.unpostedMovements,
    required this.countByType,
    required this.valueByType,
    required this.totalInflow,
    required this.totalOutflow,
    required this.netMovement,
  });
}
