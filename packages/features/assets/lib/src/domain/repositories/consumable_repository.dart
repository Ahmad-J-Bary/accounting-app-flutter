import 'package:dartz/dartz.dart';
import 'package:foundation/foundation.dart';
import '../entities/asset_entities.dart';
import '../failures/asset_failures.dart';

/// واجهة مستودع المستهلكات
abstract class ConsumableRepository {
  /// الحصول على مستهلك بواسطة المعرف
  Future<Either<AssetFailure, ConsumableItem>> getById(UniqueId id);
  
  /// الحصول على مستهلك بواسطة الكود
  Future<Either<AssetFailure, ConsumableItem>> getByCode(String code);
  
  /// الحصول على قائمة المستهلكات
  Future<Either<AssetFailure, List<ConsumableItem>>> getAll({
    ConsumableStatus? status,
    UniqueId? categoryId,
    String? location,
    bool? isActive,
    bool? lowStock,
  });
  
  /// إنشاء مستهلك جديد
  Future<Either<AssetFailure, ConsumableItem>> create(ConsumableItem item);
  
  /// تحديث مستهلك
  Future<Either<AssetFailure, ConsumableItem>> update(ConsumableItem item);
  
  /// حذف مستهلك
  Future<Either<AssetFailure, Unit>> delete(UniqueId id);
  
  /// البحث في المستهلكات
  Future<Either<AssetFailure, List<ConsumableItem>>> search(String query);
  
  /// الحصول على ملخص المستهلكات
  Future<Either<AssetFailure, ConsumablesSummary>> getSummary();
  
  /// صرف كمية من المستهلك
  Future<Either<AssetFailure, ConsumableItem>> issue(
    UniqueId id,
    Quantity quantity,
    DateTime date,
    String? referenceNo,
    String? notes,
  );
  
  /// استلام كمية جديدة
  Future<Either<AssetFailure, ConsumableItem>> receive(
    UniqueId id,
    Quantity quantity,
    Money unitCost,
    Currency currency,
    MoneyFxRate fxRate,
    DateTime date,
    String? referenceNo,
    String? notes,
  );
  
  /// تسوية المخزون
  Future<Either<AssetFailure, ConsumableItem>> adjustStock(
    UniqueId id,
    Quantity newQuantity,
    String reason,
    DateTime date,
  );
}

/// ملخص المستهلكات
class ConsumablesSummary {
  final int totalCount;
  final int inStockCount;
  final int lowStockCount;
  final Quantity totalQuantity;
  final Money totalValue;
  final Money totalIssuedValue;
  final Money totalConsumedValue;
  final Map<String, int> countByCategory;
  final Map<String, Quantity> quantityByCategory;
  final Map<String, Money> valueByCategory;

  const ConsumablesSummary({
    required this.totalCount,
    required this.inStockCount,
    required this.lowStockCount,
    required this.totalQuantity,
    required this.totalValue,
    required this.totalIssuedValue,
    required this.totalConsumedValue,
    required this.countByCategory,
    required this.quantityByCategory,
    required this.valueByCategory,
  });

  factory ConsumablesSummary.empty(Currency currency) {
    return ConsumablesSummary(
      totalCount: 0,
      inStockCount: 0,
      lowStockCount: 0,
      totalQuantity: Quantity.zero(),
      totalValue: Money.zero(currency),
      totalIssuedValue: Money.zero(currency),
      totalConsumedValue: Money.zero(currency),
      countByCategory: {},
      quantityByCategory: {},
      valueByCategory: {},
    );
  }
}
