import 'package:dartz/dartz.dart';
import 'package:foundation/foundation.dart';
import '../../../domain/domain.dart';
import '../models/asset_models.dart';

/// تنفيذ مستودع المستهلكات
class ConsumableRepositoryImpl implements ConsumableRepository {
  final Map<UniqueId, ConsumableModel> _cache = {};
  int _autoIncrementId = 0;

  ConsumableRepositoryImpl();

  String _generateCode() {
    _autoIncrementId++;
    return 'CON-${DateTime.now().year}-${_autoIncrementId.toString().padLeft(4, '0')}';
  }

  @override
  Future<Either<AssetFailure, ConsumableItem>> getById(UniqueId id) async {
    try {
      final cached = _cache[id];
      if (cached != null) {
        return Right(cached.toEntity());
      }
      return Left(ConsumableNotFoundFailure(id));
    } catch (e) {
      return Left(InvalidConsumableFailure('خطأ في جلب المستهلك: $e'));
    }
  }

  @override
  Future<Either<AssetFailure, ConsumableItem>> getByCode(String code) async {
    try {
      final cached = _cache.values.firstWhere(
        (model) => model.code == code,
        orElse: () => throw Exception('Not found'),
      );
      return Right(cached.toEntity());
    } catch (e) {
      return Left(InvalidConsumableFailure('المستهلك بالكود $code غير موجود'));
    }
  }

  @override
  Future<Either<AssetFailure, List<ConsumableItem>>> getAll({
    ConsumableStatus? status,
    UniqueId? categoryId,
    String? location,
    bool? isActive,
    bool? lowStock,
  }) async {
    try {
      var models = _cache.values.toList();

      // تطبيق الفلاتر
      if (status != null) {
        models = models.where((m) => m.status == status.englishName).toList();
      }
      if (categoryId != null) {
        models = models.where((m) => m.categoryId == categoryId.value).toList();
      }
      if (location != null) {
        models = models.where((m) => m.location == location).toList();
      }
      if (isActive != null) {
        models = models.where((m) => m.isActive == (isActive ? 1 : 0)).toList();
      }
      if (lowStock == true) {
        models = models.where((m) => 
            m.status == 'low_stock' || (m.minStockLevel != null && m.quantityOnHand < m.minStockLevel!)).toList();
      }

      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(InvalidConsumableFailure('خطأ في جلب المستهلكات: $e'));
    }
  }

  @override
  Future<Either<AssetFailure, ConsumableItem>> create(ConsumableItem item) async {
    try {
      // التحقق من عدم تكرار الكود
      final codeExists = _cache.values.any((m) => m.code == item.code);
      if (codeExists) {
        return Left(InvalidConsumableFailure('كود المستهلك ${item.code} مستخدم بالفعل'));
      }

      var model = ConsumableModel.fromEntity(item);
      
      // إذا لم يكن هناك كود، قم بتوليد واحد
      if (model.code.isEmpty) {
        model = model.copyWith(code: _generateCode());
      }

      // تحديد الحالة بناءً على الكمية
      final status = _determineStatus(model.quantityOnHand, model.minStockLevel);
      model = model.copyWith(status: status.englishName);

      _cache[item.id] = model;
      return Right(model.toEntity());
    } catch (e) {
      return Left(InvalidConsumableFailure('خطأ في إنشاء المستهلك: $e'));
    }
  }

  @override
  Future<Either<AssetFailure, ConsumableItem>> update(ConsumableItem item) async {
    try {
      var model = ConsumableModel.fromEntity(item);
      
      // تحديث الحالة بناءً على الكمية
      final status = _determineStatus(model.quantityOnHand, model.minStockLevel);
      model = model.copyWith(status: status.englishName);

      _cache[item.id] = model;
      return Right(model.toEntity());
    } catch (e) {
      return Left(InvalidConsumableFailure('خطأ في تحديث المستهلك: $e'));
    }
  }

  @override
  Future<Either<AssetFailure, Unit>> delete(UniqueId id) async {
    try {
      _cache.remove(id);
      return const Right(unit);
    } catch (e) {
      return Left(InvalidConsumableFailure('خطأ في حذف المستهلك: $e'));
    }
  }

  @override
  Future<Either<AssetFailure, List<ConsumableItem>>> search(String query) async {
    try {
      final lowerQuery = query.toLowerCase();
      final models = _cache.values.where((m) {
        return m.name.toLowerCase().contains(lowerQuery) ||
            m.code.toLowerCase().contains(lowerQuery) ||
            (m.location?.toLowerCase().contains(lowerQuery) ?? false);
      }).toList();

      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(InvalidConsumableFailure('خطأ في البحث: $e'));
    }
  }

  @override
  Future<Either<AssetFailure, ConsumablesSummary>> getSummary() async {
    try {
      final models = _cache.values.toList();
      
      if (models.isEmpty) {
        return Right(ConsumablesSummary.empty(Currency.syp()));
      }

      final currency = models.first.currencyCode == 'SYP'
          ? Currency.syp()
          : Currency.usd();

      final totalCount = models.length;
      final inStockCount = models.where((m) => m.quantityOnHand > 0).length;
      final lowStockCount = models.where((m) => m.status == 'low_stock').length;

      double totalQuantity = 0;
      double totalValue = 0;
      double totalIssuedValue = 0;
      double totalConsumedValue = 0;

      final countByCategory = <String, int>{};
      final quantityByCategory = <String, double>{};
      final valueByCategory = <String, double>{};

      for (final model in models) {
        totalQuantity += model.quantityOnHand;
        totalValue += model.totalCost;

        final categoryName = model.categoryName ?? 'غير مصنف';
        countByCategory[categoryName] = (countByCategory[categoryName] ?? 0) + 1;
        quantityByCategory[categoryName] = (quantityByCategory[categoryName] ?? 0) + model.quantityOnHand;
        valueByCategory[categoryName] = (valueByCategory[categoryName] ?? 0) + model.totalCost;
      }

      return Right(ConsumablesSummary(
        totalCount: totalCount,
        inStockCount: inStockCount,
        lowStockCount: lowStockCount,
        totalQuantity: Quantity(totalQuantity, 'units'),
        totalValue: Money.fromDouble(totalValue, currency),
        totalIssuedValue: Money.fromDouble(totalIssuedValue, currency),
        totalConsumedValue: Money.fromDouble(totalConsumedValue, currency),
        countByCategory: countByCategory,
        quantityByCategory: quantityByCategory.map(
          (key, value) => MapEntry(key, Quantity(value, 'units')),
        ),
        valueByCategory: valueByCategory.map(
          (key, value) => MapEntry(key, Money.fromDouble(value, currency)),
        ),
      ));
    } catch (e) {
      return Left(InvalidConsumableFailure('خطأ في حساب الملخص: $e'));
    }
  }

  @override
  Future<Either<AssetFailure, ConsumableItem>> issue(
    UniqueId id,
    Quantity quantity,
    DateTime date,
    String? referenceNo,
    String? notes,
  ) async {
    try {
      final model = _cache[id];
      if (model == null) {
        return Left(ConsumableNotFoundFailure(id));
      }

      final newQuantity = model.quantityOnHand - quantity.value;
      if (newQuantity < 0) {
        return Left(InsufficientConsumableStockFailure(
          required: quantity,
          available: Quantity(model.quantityOnHand, 'unit'),
        ));
      }

      final newTotalCost = model.unitCost * newQuantity;
      final status = _determineStatus(newQuantity, model.minStockLevel);

      final updatedModel = model.copyWith(
        quantityOnHand: newQuantity,
        totalCost: newTotalCost,
        status: status.englishName,
        updatedAt: DateTime.now().toIso8601String(),
      );

      _cache[id] = updatedModel;
      return Right(updatedModel.toEntity());
    } catch (e) {
      return Left(InvalidConsumableFailure('خطأ في صرف المستهلك: $e'));
    }
  }

  @override
  Future<Either<AssetFailure, ConsumableItem>> receive(
    UniqueId id,
    Quantity quantity,
    Money unitCost,
    Currency currency,
    MoneyFxRate fxRate,
    DateTime date,
    String? referenceNo,
    String? notes,
  ) async {
    try {
      final model = _cache[id];
      if (model == null) {
        return Left(ConsumableNotFoundFailure(id));
      }

      final newQuantity = model.quantityOnHand + quantity.value;
      
      // حساب متوسط التكلفة
      final totalExistingCost = model.unitCost * model.quantityOnHand;
      final totalNewCost = unitCost.amount * quantity.value;
      final combinedTotalCost = totalExistingCost + totalNewCost;
      final averageUnitCost = newQuantity > 0 ? combinedTotalCost / newQuantity : unitCost.amount;

      final status = _determineStatus(newQuantity, model.minStockLevel);

      final updatedModel = model.copyWith(
        quantityOnHand: newQuantity,
        unitCost: averageUnitCost,
        totalCost: combinedTotalCost,
        status: status.englishName,
        updatedAt: DateTime.now().toIso8601String(),
      );

      _cache[id] = updatedModel;
      return Right(updatedModel.toEntity());
    } catch (e) {
      return Left(InvalidConsumableFailure('خطأ في استلام المستهلك: $e'));
    }
  }

  @override
  Future<Either<AssetFailure, ConsumableItem>> adjustStock(
    UniqueId id,
    Quantity newQuantity,
    String reason,
    DateTime date,
  ) async {
    try {
      final model = _cache[id];
      if (model == null) {
        return Left(ConsumableNotFoundFailure(id));
      }

      final newTotalCost = model.unitCost * newQuantity.value;
      final status = _determineStatus(newQuantity.value, model.minStockLevel);

      final updatedModel = model.copyWith(
        quantityOnHand: newQuantity.value,
        totalCost: newTotalCost,
        status: status.englishName,
        updatedAt: DateTime.now().toIso8601String(),
      );

      _cache[id] = updatedModel;
      return Right(updatedModel.toEntity());
    } catch (e) {
      return Left(InvalidConsumableFailure('خطأ في تسوية المخزون: $e'));
    }
  }

  ConsumableStatus _determineStatus(double quantity, double? minStockLevel) {
    if (quantity <= 0) {
      return ConsumableStatus.exhausted;
    }
    if (minStockLevel != null && quantity < minStockLevel) {
      return ConsumableStatus.lowStock;
    }
    return ConsumableStatus.inStock;
  }
}

/// إمتداد للنسخة المعدلة
extension ConsumableModelExtension on ConsumableModel {
  ConsumableModel copyWith({
    String? code,
    double? quantityOnHand,
    double? unitCost,
    double? totalCost,
    String? status,
    int? isActive,
    String? updatedAt,
  }) {
    return ConsumableModel(
      id: id,
      code: code ?? this.code,
      name: name,
      categoryId: categoryId,
      categoryName: categoryName,
      quantityOnHand: quantityOnHand ?? this.quantityOnHand,
      unitOfMeasure: unitOfMeasure,
      unitCost: unitCost ?? this.unitCost,
      currencyCode: currencyCode,
      fxRate: fxRate,
      fxRateDate: fxRateDate,
      totalCost: totalCost ?? this.totalCost,
      status: status ?? this.status,
      location: location,
      notes: notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      journalEntryId: journalEntryId,
      minStockLevel: minStockLevel,
    );
  }
}
