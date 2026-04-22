import 'package:dartz/dartz.dart';
import 'package:foundation/foundation.dart';
import '../../../domain/domain.dart';
import '../models/asset_models.dart';

/// تنفيذ مستودع حركات الأصول
class AssetMovementRepositoryImpl implements AssetMovementRepository {
  final Map<UniqueId, AssetMovementModel> _cache = {};

  AssetMovementRepositoryImpl();

  @override
  Future<Either<AssetFailure, AssetMovement>> getById(UniqueId id) async {
    try {
      final cached = _cache[id];
      if (cached != null) {
        return Right(cached.toEntity());
      }
      return Left(InvalidAssetMovementFailure('الحركة غير موجودة'));
    } catch (e) {
      return Left(InvalidAssetMovementFailure('خطأ في جلب الحركة: $e'));
    }
  }

  @override
  Future<Either<AssetFailure, List<AssetMovement>>> getByAssetId(
    UniqueId assetId, {
    AssetType? type,
    AssetMovementType? movementType,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      var models = _cache.values.where((m) => m.assetId == assetId.value).toList();

      if (type != null) {
        models = models.where((m) => m.assetType == type.name).toList();
      }
      if (movementType != null) {
        models = models.where((m) => m.movementType == movementType.englishName).toList();
      }
      if (fromDate != null) {
        models = models.where((m) => DateTime.parse(m.date).isAfter(fromDate) ||
            DateTime.parse(m.date).isAtSameMomentAs(fromDate)).toList();
      }
      if (toDate != null) {
        models = models.where((m) => DateTime.parse(m.date).isBefore(toDate) ||
            DateTime.parse(m.date).isAtSameMomentAs(toDate)).toList();
      }

      // ترتيب حسب التاريخ (الأحدث أولاً)
      models.sort((a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)));

      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(InvalidAssetMovementFailure('خطأ في جلب الحركات: $e'));
    }
  }

  @override
  Future<Either<AssetFailure, List<AssetMovement>>> getAll({
    AssetType? assetType,
    AssetMovementType? movementType,
    DateTime? fromDate,
    DateTime? toDate,
    String? referenceNo,
    bool? isPosted,
    int? limit,
    int? offset,
  }) async {
    try {
      var models = _cache.values.toList();

      if (assetType != null) {
        models = models.where((m) => m.assetType == assetType.name).toList();
      }
      if (movementType != null) {
        models = models.where((m) => m.movementType == movementType.englishName).toList();
      }
      if (fromDate != null) {
        models = models.where((m) => DateTime.parse(m.date).isAfter(fromDate) ||
            DateTime.parse(m.date).isAtSameMomentAs(fromDate)).toList();
      }
      if (toDate != null) {
        models = models.where((m) => DateTime.parse(m.date).isBefore(toDate) ||
            DateTime.parse(m.date).isAtSameMomentAs(toDate)).toList();
      }
      if (referenceNo != null) {
        models = models.where((m) => m.referenceNo == referenceNo).toList();
      }
      if (isPosted != null) {
        models = models.where((m) => m.isPosted == (isPosted ? 1 : 0)).toList();
      }

      // ترتيب حسب التاريخ (الأحدث أولاً)
      models.sort((a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)));

      // تطبيق pagination
      if (offset != null && offset > 0) {
        models = models.skip(offset).toList();
      }
      if (limit != null && limit > 0) {
        models = models.take(limit).toList();
      }

      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(InvalidAssetMovementFailure('خطأ في جلب الحركات: $e'));
    }
  }

  @override
  Future<Either<AssetFailure, AssetMovement>> create(AssetMovement movement) async {
    try {
      final model = AssetMovementModel.fromEntity(movement);
      _cache[movement.id] = model;
      return Right(model.toEntity());
    } catch (e) {
      return Left(InvalidAssetMovementFailure('خطأ في إنشاء الحركة: $e'));
    }
  }

  @override
  Future<Either<AssetFailure, AssetMovement>> update(AssetMovement movement) async {
    try {
      final model = AssetMovementModel.fromEntity(movement);
      _cache[movement.id] = model;
      return Right(model.toEntity());
    } catch (e) {
      return Left(InvalidAssetMovementFailure('خطأ في تحديث الحركة: $e'));
    }
  }

  @override
  Future<Either<AssetFailure, Unit>> delete(UniqueId id) async {
    try {
      _cache.remove(id);
      return const Right(unit);
    } catch (e) {
      return Left(InvalidAssetMovementFailure('خطأ في حذف الحركة: $e'));
    }
  }

  @override
  Future<Either<AssetFailure, AssetMovement>> post(
    UniqueId movementId,
    UniqueId journalEntryId,
  ) async {
    try {
      final model = _cache[movementId];
      if (model == null) {
        return Left(InvalidAssetMovementFailure('الحركة غير موجودة'));
      }

      final updatedModel = model.copyWith(
        journalEntryId: journalEntryId.value,
        isPosted: 1,
      );

      _cache[movementId] = updatedModel;
      return Right(updatedModel.toEntity());
    } catch (e) {
      return Left(InvalidAssetMovementFailure('خطأ في ترحيل الحركة: $e'));
    }
  }

  @override
  Future<Either<AssetFailure, AssetMovement>> reverse(UniqueId movementId) async {
    try {
      final model = _cache[movementId];
      if (model == null) {
        return Left(InvalidAssetMovementFailure('الحركة غير موجودة'));
      }

      // إلغاء الترحيل
      final updatedModel = model.copyWith(
        journalEntryId: null,
        isPosted: 0,
      );

      _cache[movementId] = updatedModel;
      return Right(updatedModel.toEntity());
    } catch (e) {
      return Left(InvalidAssetMovementFailure('خطأ في عكس الترحيل: $e'));
    }
  }

  @override
  Future<Either<AssetFailure, AssetMovementsSummary>> getSummary({
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      var models = _cache.values.toList();

      if (fromDate != null) {
        models = models.where((m) => DateTime.parse(m.date).isAfter(fromDate) ||
            DateTime.parse(m.date).isAtSameMomentAs(fromDate)).toList();
      }
      if (toDate != null) {
        models = models.where((m) => DateTime.parse(m.date).isBefore(toDate) ||
            DateTime.parse(m.date).isAtSameMomentAs(toDate)).toList();
      }

      final totalMovements = models.length;
      final postedMovements = models.where((m) => m.isPosted == 1).length;
      final unpostedMovements = totalMovements - postedMovements;

      final countByType = <AssetMovementType, int>{};
      final valueByType = <AssetMovementType, double>{};

      double totalInflow = 0;
      double totalOutflow = 0;

      final currency = models.isNotEmpty
          ? (models.first.currencyCode == 'SYP' ? Currency.syp() : Currency.usd())
          : Currency.syp();

      for (final model in models) {
        final type = _parseMovementType(model.movementType);
        countByType[type] = (countByType[type] ?? 0) + 1;
        valueByType[type] = (valueByType[type] ?? 0) + model.amount;

        // حساب التدفقات
        if (model.movementType == 'acquisition' || model.movementType == 'revaluation') {
          totalInflow += model.amount;
        } else if (model.movementType == 'disposal' || 
                   model.movementType == 'sale' || 
                   model.movementType == 'consumption' ||
                   model.movementType == 'issue') {
          totalOutflow += model.amount;
        }
      }

      return Right(AssetMovementsSummary(
        totalMovements: totalMovements,
        postedMovements: postedMovements,
        unpostedMovements: unpostedMovements,
        countByType: countByType,
        valueByType: valueByType.map(
          (key, value) => MapEntry(key, Money.fromDouble(value, currency)),
        ),
        totalInflow: Money.fromDouble(totalInflow, currency),
        totalOutflow: Money.fromDouble(totalOutflow, currency),
        netMovement: Money.fromDouble(totalInflow - totalOutflow, currency),
      ));
    } catch (e) {
      return Left(InvalidAssetMovementFailure('خطأ في حساب الملخص: $e'));
    }
  }

  AssetMovementType _parseMovementType(String type) {
    switch (type.toLowerCase()) {
      case 'acquisition':
        return AssetMovementType.acquisition;
      case 'depreciation':
        return AssetMovementType.depreciation;
      case 'disposal':
        return AssetMovementType.disposal;
      case 'sale':
        return AssetMovementType.sale;
      case 'adjustment':
        return AssetMovementType.adjustment;
      case 'transfer':
        return AssetMovementType.transfer;
      case 'issue':
        return AssetMovementType.issue;
      case 'consumption':
        return AssetMovementType.consumption;
      case 'damage':
        return AssetMovementType.damage;
      case 'revaluation':
        return AssetMovementType.revaluation;
      case 'return':
        return AssetMovementType.return;
      default:
        return AssetMovementType.acquisition;
    }
  }
}

/// إمتداد للنسخة المعدلة
extension AssetMovementModelExtension on AssetMovementModel {
  AssetMovementModel copyWith({
    String? journalEntryId,
    int? isPosted,
  }) {
    return AssetMovementModel(
      id: id,
      assetId: assetId,
      assetType: assetType,
      movementType: movementType,
      date: date,
      quantity: quantity,
      amount: amount,
      currencyCode: currencyCode,
      fxRate: fxRate,
      fxRateDate: fxRateDate,
      description: description,
      referenceNo: referenceNo,
      journalEntryId: journalEntryId ?? this.journalEntryId,
      partnerId: partnerId,
      partnerName: partnerName,
      location: location,
      notes: notes,
      isPosted: isPosted ?? this.isPosted,
      createdAt: createdAt,
      createdBy: createdBy,
    );
  }
}
