import 'package:dartz/dartz.dart';
import 'package:foundation/foundation.dart';
import '../../../domain/domain.dart';
import '../models/asset_models.dart';

/// تنفيذ مستودع الأصول الثابتة
/// يدعم التخزين المحلي مع نظام كاش
class FixedAssetRepositoryImpl implements FixedAssetRepository {
  // TODO: Inject actual database when available
  // final AppDatabase _database;
  
  final Map<UniqueId, FixedAssetModel> _cache = {};
  int _autoIncrementId = 0;

  FixedAssetRepositoryImpl();

  String _generateCode() {
    _autoIncrementId++;
    return 'FA-${DateTime.now().year}-${_autoIncrementId.toString().padLeft(4, '0')}';
  }

  @override
  Future<Either<AssetFailure, FixedAsset>> getById(UniqueId id) async {
    try {
      final cached = _cache[id];
      if (cached != null) {
        return Right(cached.toEntity());
      }

      // TODO: Query from actual database
      return Left(AssetNotFoundFailure(id));
    } catch (e) {
      return Left(InvalidAssetFailure('خطأ في جلب الأصل: $e'));
    }
  }

  @override
  Future<Either<AssetFailure, FixedAsset>> getByCode(String code) async {
    try {
      final cached = _cache.values.firstWhere(
        (model) => model.code == code,
        orElse: () => throw Exception('Not found'),
      );
      return Right(cached.toEntity());
    } catch (e) {
      return Left(InvalidAssetFailure('الأصل بالكود $code غير موجود'));
    }
  }

  @override
  Future<Either<AssetFailure, List<FixedAsset>>> getAll({
    AssetStatus? status,
    UniqueId? categoryId,
    String? location,
    bool? isActive,
    DateTime? fromDate,
    DateTime? toDate,
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
      if (fromDate != null) {
        models = models.where((m) => DateTime.parse(m.purchaseDate).isAfter(fromDate) ||
            DateTime.parse(m.purchaseDate).isAtSameMomentAs(fromDate)).toList();
      }
      if (toDate != null) {
        models = models.where((m) => DateTime.parse(m.purchaseDate).isBefore(toDate) ||
            DateTime.parse(m.purchaseDate).isAtSameMomentAs(toDate)).toList();
      }

      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(InvalidAssetFailure('خطأ في جلب الأصول: $e'));
    }
  }

  @override
  Future<Either<AssetFailure, FixedAsset>> create(FixedAsset asset) async {
    try {
      // التحقق من عدم تكرار الكود
      final codeExists = _cache.values.any((m) => m.code == asset.code);
      if (codeExists) {
        return Left(InvalidAssetFailure('كود الأصل ${asset.code} مستخدم بالفعل'));
      }

      final model = FixedAssetModel.fromEntity(asset);
      
      // إذا لم يكن هناك كود، قم بتوليد واحد
      final finalModel = model.code.isEmpty
          ? model.copyWith(code: _generateCode())
          : model;

      _cache[asset.id] = finalModel;
      
      // TODO: Save to actual database
      return Right(finalModel.toEntity());
    } catch (e) {
      return Left(InvalidAssetFailure('خطأ في إنشاء الأصل: $e'));
    }
  }

  @override
  Future<Either<AssetFailure, FixedAsset>> update(FixedAsset asset) async {
    try {
      final model = FixedAssetModel.fromEntity(asset);
      _cache[asset.id] = model;
      
      // TODO: Update in actual database
      return Right(model.toEntity());
    } catch (e) {
      return Left(InvalidAssetFailure('خطأ في تحديث الأصل: $e'));
    }
  }

  @override
  Future<Either<AssetFailure, Unit>> delete(UniqueId id) async {
    try {
      _cache.remove(id);
      
      // TODO: Delete from actual database
      return const Right(unit);
    } catch (e) {
      return Left(InvalidAssetFailure('خطأ في حذف الأصل: $e'));
    }
  }

  @override
  Future<Either<AssetFailure, List<FixedAsset>>> search(String query) async {
    try {
      final lowerQuery = query.toLowerCase();
      final models = _cache.values.where((m) {
        return m.name.toLowerCase().contains(lowerQuery) ||
            m.code.toLowerCase().contains(lowerQuery) ||
            (m.location?.toLowerCase().contains(lowerQuery) ?? false) ||
            (m.notes?.toLowerCase().contains(lowerQuery) ?? false);
      }).toList();

      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(InvalidAssetFailure('خطأ في البحث: $e'));
    }
  }

  @override
  Future<Either<AssetFailure, FixedAssetsSummary>> getSummary() async {
    try {
      final models = _cache.values.toList();
      
      if (models.isEmpty) {
        return Right(FixedAssetsSummary.empty(Currency.syp()));
      }

      final currency = models.first.currencyCode == 'SYP'
          ? Currency.syp()
          : Currency.usd();

      final totalCount = models.length;
      final activeCount = models.where((m) => m.status == 'active').length;
      final disposedCount = models.where((m) => 
          m.status == 'disposed' || m.status == 'sold').length;

      double totalCost = 0;
      double totalAccumulatedDepreciation = 0;
      double totalNetBookValue = 0;

      final countByCategory = <String, int>{};
      final valueByCategory = <String, double>{};

      for (final model in models) {
        totalCost += model.purchaseCost;
        totalAccumulatedDepreciation += model.accumulatedDepreciation;
        totalNetBookValue += model.netBookValue;

        final categoryName = model.categoryName ?? 'غير مصنف';
        countByCategory[categoryName] = (countByCategory[categoryName] ?? 0) + 1;
        valueByCategory[categoryName] = (valueByCategory[categoryName] ?? 0) + model.netBookValue;
      }

      return Right(FixedAssetsSummary(
        totalCount: totalCount,
        activeCount: activeCount,
        disposedCount: disposedCount,
        totalCost: Money.fromDouble(totalCost, currency),
        totalAccumulatedDepreciation: Money.fromDouble(totalAccumulatedDepreciation, currency),
        totalNetBookValue: Money.fromDouble(totalNetBookValue, currency),
        countByCategory: countByCategory,
        valueByCategory: valueByCategory.map(
          (key, value) => MapEntry(key, Money.fromDouble(value, currency)),
        ),
      ));
    } catch (e) {
      return Left(InvalidAssetFailure('خطأ في حساب الملخص: $e'));
    }
  }
}

/// إمتداد للنسخة المعدلة
extension FixedAssetModelExtension on FixedAssetModel {
  FixedAssetModel copyWith({
    String? code,
    int? isActive,
    String? updatedAt,
  }) {
    return FixedAssetModel(
      id: id,
      code: code ?? this.code,
      name: name,
      categoryId: categoryId,
      categoryName: categoryName,
      purchaseDate: purchaseDate,
      purchaseCost: purchaseCost,
      currencyCode: currencyCode,
      fxRate: fxRate,
      fxRateDate: fxRateDate,
      usefulLifeMonths: usefulLifeMonths,
      salvageValue: salvageValue,
      accumulatedDepreciation: accumulatedDepreciation,
      netBookValue: netBookValue,
      status: status,
      location: location,
      notes: notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      journalEntryId: journalEntryId,
    );
  }
}
