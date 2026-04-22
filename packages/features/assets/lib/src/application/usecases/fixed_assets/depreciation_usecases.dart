import 'package:dartz/dartz.dart';
import 'package:foundation/foundation.dart';
import '../../../domain/domain.dart';

/// معلمات توليد جدول الاهلاك
class GenerateDepreciationScheduleParams {
  final UniqueId fixedAssetId;
  final DepreciationMethod method;
  final String createdBy;

  const GenerateDepreciationScheduleParams({
    required this.fixedAssetId,
    this.method = DepreciationMethod.straightLine,
    required this.createdBy,
  });
}

/// حالة استخدام: توليد جدول اهلاك
class GenerateDepreciationScheduleUseCase {
  final FixedAssetRepository _repository;
  final AuditLogService _auditLog;

  GenerateDepreciationScheduleUseCase({
    required FixedAssetRepository repository,
    required AuditLogService auditLog,
  })  : _repository = repository,
        _auditLog = auditLog;

  Future<Either<AssetFailure, DepreciationSchedule>> call(
    GenerateDepreciationScheduleParams params,
  ) async {
    final assetResult = await _repository.getById(params.fixedAssetId);
    
    return assetResult.fold(
      (failure) => Left(failure),
      (asset) async {
        // التحقق من صلاحية الاهلاك
        if (asset.usefulLifeMonths <= 0) {
          return Left(InvalidDepreciationFailure.invalidLife());
        }

        // حساب الاهلاك الشهري
        final monthlyDepreciation = asset.monthlyDepreciation;
        
        // إنشاء الجدول
        final schedule = DepreciationSchedule(
          id: UniqueId.generate(),
          fixedAssetId: asset.id,
          fixedAssetName: asset.name,
          startDate: asset.purchaseDate,
          usefulLifeMonths: asset.usefulLifeMonths,
          method: params.method,
          monthlyDepreciation: monthlyDepreciation,
          accumulatedDepreciation: Money.zero(asset.currency),
          remainingValue: asset.purchaseCost,
          remainingMonths: asset.usefulLifeMonths,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _auditLog.log(
          action: 'GENERATE_DEPRECIATION_SCHEDULE',
          entityType: 'DepreciationSchedule',
          entityId: schedule.id.value,
          userId: params.createdBy,
          details: {
            'assetCode': asset.code,
            'assetName': asset.name,
            'method': params.method.displayName,
            'monthlyAmount': monthlyDepreciation.amount.toString(),
          },
        );

        return Right(schedule);
      },
    );
  }
}

/// معلمات تسجيل اهلاك شهري
class PostMonthlyDepreciationParams {
  final UniqueId fixedAssetId;
  final DateTime postingDate;
  final int? periodNumber; // رقم الفترة (اختياري)
  final String postedBy;

  const PostMonthlyDepreciationParams({
    required this.fixedAssetId,
    required this.postingDate,
    this.periodNumber,
    required this.postedBy,
  });
}

/// حالة استخدام: تسجيل اهلاك شهري
class PostMonthlyDepreciationUseCase {
  final FixedAssetRepository _repository;
  final AssetMovementRepository _movementRepository;
  final AuditLogService _auditLog;

  PostMonthlyDepreciationUseCase({
    required FixedAssetRepository repository,
    required AssetMovementRepository movementRepository,
    required AuditLogService auditLog,
  })  : _repository = repository,
        _movementRepository = movementRepository,
        _auditLog = auditLog;

  Future<Either<AssetFailure, FixedAsset>> call(PostMonthlyDepreciationParams params) async {
    final assetResult = await _repository.getById(params.fixedAssetId);
    
    return assetResult.fold(
      (failure) => Left(failure),
      (asset) async {
        // حساب مبلغ الاهلاك
        final depreciationAmount = asset.monthlyDepreciation;
        
        // التحقق من السياسات
        final validationResult = FixedAssetPolicy.validateDepreciation(asset, depreciationAmount);
        if (validationResult.isLeft()) {
          return Left((validationResult as Left).value);
        }

        // تحديث قيم الاهلاك
        final newAccumulatedDepreciation = asset.accumulatedDepreciation.add(depreciationAmount);
        final newNetBookValue = asset.netBookValue.subtract(depreciationAmount);
        
        // التأكد من عدم تجاوز القيمة الصفرية
        final finalNetBookValue = newNetBookValue.amount < 0 
            ? Money.zero(asset.currency) 
            : newNetBookValue;

        final updatedAsset = asset.copyWith(
          accumulatedDepreciation: newAccumulatedDepreciation,
          netBookValue: finalNetBookValue,
          status: finalNetBookValue.amount <= 0 ? AssetStatus.inactive : asset.status,
          updatedAt: DateTime.now(),
        );

        final saveResult = await _repository.update(updatedAsset);
        
        return saveResult.fold(
          (failure) => Left(failure),
          (savedAsset) async {
            // تسجيل حركة الاهلاك
            final movement = AssetMovement(
              id: UniqueId.generate(),
              assetId: savedAsset.id,
              assetType: AssetType.fixed,
              movementType: AssetMovementType.depreciation,
              date: params.postingDate,
              amount: depreciationAmount,
              currency: asset.currency,
              fxRate: asset.fxRate,
              description: 'اهلاك شهري - ${asset.name} - الفترة ${params.periodNumber ?? ''}',
              referenceNo: 'DEP-${asset.code}-${params.postingDate.year}-${params.postingDate.month}',
              createdAt: DateTime.now(),
              createdBy: params.postedBy,
            );

            await _movementRepository.create(movement);

            await _auditLog.log(
              action: 'POST_DEPRECIATION',
              entityType: 'FixedAsset',
              entityId: savedAsset.id.value,
              userId: params.postedBy,
              details: {
                'code': asset.code,
                'amount': depreciationAmount.amount.toString(),
                'accumulated': newAccumulatedDepreciation.amount.toString(),
                'netBookValue': finalNetBookValue.amount.toString(),
                'period': params.periodNumber?.toString(),
              },
            );

            return Right(savedAsset);
          },
        );
      },
    );
  }
}
