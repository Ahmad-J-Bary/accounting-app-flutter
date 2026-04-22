import 'package:dartz/dartz.dart';
import 'package:foundation/foundation.dart';
import '../entities/asset_entities.dart';
import '../failures/asset_failures.dart';

/// واجهة مستودع الأصول الثابتة
abstract class FixedAssetRepository {
  /// الحصول على أصل ثابت بواسطة المعرف
  Future<Either<AssetFailure, FixedAsset>> getById(UniqueId id);
  
  /// الحصول على أصل ثابت بواسطة الكود
  Future<Either<AssetFailure, FixedAsset>> getByCode(String code);
  
  /// الحصول على قائمة الأصول الثابتة
  Future<Either<AssetFailure, List<FixedAsset>>> getAll({
    AssetStatus? status,
    UniqueId? categoryId,
    String? location,
    bool? isActive,
    DateTime? fromDate,
    DateTime? toDate,
  });
  
  /// إنشاء أصل ثابت جديد
  Future<Either<AssetFailure, FixedAsset>> create(FixedAsset asset);
  
  /// تحديث أصل ثابت
  Future<Either<AssetFailure, FixedAsset>> update(FixedAsset asset);
  
  /// حذف أصل ثابت
  Future<Either<AssetFailure, Unit>> delete(UniqueId id);
  
  /// البحث في الأصول الثابتة
  Future<Either<AssetFailure, List<FixedAsset>>> search(String query);
  
  /// الحصول على ملخص الأصول الثابتة
  Future<Either<AssetFailure, FixedAssetsSummary>> getSummary();
}

/// ملخص الأصول الثابتة
class FixedAssetsSummary {
  final int totalCount;
  final int activeCount;
  final int disposedCount;
  final Money totalCost;
  final Money totalAccumulatedDepreciation;
  final Money totalNetBookValue;
  final Map<String, int> countByCategory;
  final Map<String, Money> valueByCategory;

  const FixedAssetsSummary({
    required this.totalCount,
    required this.activeCount,
    required this.disposedCount,
    required this.totalCost,
    required this.totalAccumulatedDepreciation,
    required this.totalNetBookValue,
    required this.countByCategory,
    required this.valueByCategory,
  });

  factory FixedAssetsSummary.empty(Currency currency) {
    return FixedAssetsSummary(
      totalCount: 0,
      activeCount: 0,
      disposedCount: 0,
      totalCost: Money.zero(currency),
      totalAccumulatedDepreciation: Money.zero(currency),
      totalNetBookValue: Money.zero(currency),
      countByCategory: {},
      valueByCategory: {},
    );
  }
}
