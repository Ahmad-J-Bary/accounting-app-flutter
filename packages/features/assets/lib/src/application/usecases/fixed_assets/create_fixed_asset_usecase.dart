import 'package:dartz/dartz.dart';
import 'package:foundation/foundation.dart';
import '../../../domain/domain.dart';

/// معلمات إنشاء أصل ثابت
class CreateFixedAssetParams {
  final String code;
  final String name;
  final UniqueId categoryId;
  final DateTime purchaseDate;
  final Money purchaseCost;
  final Currency currency;
  final MoneyFxRate fxRate;
  final int usefulLifeMonths;
  final Money? salvageValue;
  final String? location;
  final String? notes;
  final String createdBy;

  const CreateFixedAssetParams({
    required this.code,
    required this.name,
    required this.categoryId,
    required this.purchaseDate,
    required this.purchaseCost,
    required this.currency,
    required this.fxRate,
    required this.usefulLifeMonths,
    this.salvageValue,
    this.location,
    this.notes,
    required this.createdBy,
  });
}

/// حالة استخدام: إنشاء أصل ثابت جديد
class CreateFixedAssetUseCase {
  final FixedAssetRepository _repository;
  final AssetMovementRepository _movementRepository;
  final AuditLogService _auditLog;

  CreateFixedAssetUseCase({
    required FixedAssetRepository repository,
    required AssetMovementRepository movementRepository,
    required AuditLogService auditLog,
  })  : _repository = repository,
        _movementRepository = movementRepository,
        _auditLog = auditLog;

  Future<Either<AssetFailure, FixedAsset>> call(CreateFixedAssetParams params) async {
    // إنشاء كيان الأصل
    final now = DateTime.now();
    final asset = FixedAsset(
      id: UniqueId.generate(),
      code: params.code,
      name: params.name,
      categoryId: params.categoryId,
      purchaseDate: params.purchaseDate,
      purchaseCost: params.purchaseCost,
      currency: params.currency,
      fxRate: params.fxRate,
      usefulLifeMonths: params.usefulLifeMonths,
      salvageValue: params.salvageValue,
      accumulatedDepreciation: Money.zero(params.currency),
      netBookValue: params.purchaseCost,
      status: AssetStatus.active,
      location: params.location,
      notes: params.notes,
      createdAt: now,
      updatedAt: now,
    );

    // التحقق من السياسات
    final validationResult = FixedAssetPolicy.validateAcquisition(asset);
    if (validationResult.isLeft()) {
      return Left((validationResult as Left).value);
    }

    // حفظ الأصل
    final result = await _repository.create(asset);
    
    return result.fold(
      (failure) => Left(failure),
      (createdAsset) async {
        // تسجيل حركة الشراء
        final movement = AssetMovement(
          id: UniqueId.generate(),
          assetId: createdAsset.id,
          assetType: AssetType.fixed,
          movementType: AssetMovementType.acquisition,
          date: params.purchaseDate,
          amount: params.purchaseCost,
          currency: params.currency,
          fxRate: params.fxRate,
          description: 'شراء أصل ثابت: ${params.name}',
          referenceNo: params.code,
          createdAt: now,
          createdBy: params.createdBy,
        );

        await _movementRepository.create(movement);

        // تسجيل في Audit Log
        await _auditLog.log(
          action: 'CREATE_FIXED_ASSET',
          entityType: 'FixedAsset',
          entityId: createdAsset.id.value,
          userId: params.createdBy,
          details: {
            'code': params.code,
            'name': params.name,
            'cost': params.purchaseCost.amount.toString(),
            'currency': params.currency.code,
          },
        );

        return Right(createdAsset);
      },
    );
  }
}

/// خدمة سجل التدقيق (placeholder - يجب استبدالها بالتنفيذ الفعلي)
abstract class AuditLogService {
  Future<void> log({
    required String action,
    required String entityType,
    required String entityId,
    required String userId,
    Map<String, dynamic>? details,
  });
}
