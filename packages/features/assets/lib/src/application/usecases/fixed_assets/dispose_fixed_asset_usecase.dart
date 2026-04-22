import 'package:dartz/dartz.dart';
import 'package:foundation/foundation.dart';
import '../../../domain/domain.dart';

/// معلمات استبعاد/بيع أصل ثابت
class DisposeFixedAssetParams {
  final UniqueId id;
  final DateTime disposalDate;
  final Money? salePrice; // إذا كان البيع
  final UniqueId? buyerId; // معرف المشتري إن وجد
  final String? buyerName;
  final String? notes;
  final String disposedBy;

  const DisposeFixedAssetParams({
    required this.id,
    required this.disposalDate,
    this.salePrice,
    this.buyerId,
    this.buyerName,
    this.notes,
    required this.disposedBy,
  });
}

/// حالة استخدام: استبعاد أو بيع أصل ثابت
class DisposeFixedAssetUseCase {
  final FixedAssetRepository _repository;
  final AssetMovementRepository _movementRepository;
  final AuditLogService _auditLog;

  DisposeFixedAssetUseCase({
    required FixedAssetRepository repository,
    required AssetMovementRepository movementRepository,
    required AuditLogService auditLog,
  })  : _repository = repository,
        _movementRepository = movementRepository,
        _auditLog = auditLog;

  Future<Either<AssetFailure, FixedAsset>> call(DisposeFixedAssetParams params) async {
    // الحصول على الأصل
    final existingResult = await _repository.getById(params.id);
    
    return existingResult.fold(
      (failure) => Left(failure),
      (asset) async {
        // تحديد نوع العملية (بيع أو استبعاد)
        final isSale = params.salePrice != null && params.salePrice!.amount > 0;
        final status = isSale ? AssetStatus.sold : AssetStatus.disposed;
        
        // التحقق من السياسات
        final validationResult = isSale
            ? FixedAssetPolicy.validateSale(asset, params.salePrice!)
            : FixedAssetPolicy.validateDisposal(asset);
            
        if (validationResult.isLeft()) {
          return Left((validationResult as Left).value);
        }

        // حساب الربح أو الخسارة إذا كان بيعاً
        Money? gainOrLoss;
        if (isSale) {
          gainOrLoss = FixedAssetPolicy.calculateGainOrLoss(asset, params.salePrice!);
        }

        // تحديث حالة الأصل
        final updatedAsset = asset.copyWith(
          status: status,
          updatedAt: DateTime.now(),
        );

        final saveResult = await _repository.update(updatedAsset);
        
        return saveResult.fold(
          (failure) => Left(failure),
          (savedAsset) async {
            // إنشاء حركة الاستبعاد/البيع
            final movement = AssetMovement(
              id: UniqueId.generate(),
              assetId: savedAsset.id,
              assetType: AssetType.fixed,
              movementType: isSale ? AssetMovementType.sale : AssetMovementType.disposal,
              date: params.disposalDate,
              amount: params.salePrice ?? Money.zero(asset.currency),
              currency: asset.currency,
              fxRate: asset.fxRate,
              description: isSale
                  ? 'بيع أصل: ${asset.name} ${params.buyerName != null ? 'لـ ${params.buyerName}' : ''}'
                  : 'استبعاد أصل: ${asset.name}',
              referenceNo: asset.code,
              partnerId: params.buyerId,
              partnerName: params.buyerName,
              notes: params.notes ?? (gainOrLoss != null
                  ? 'ربح/خسارة: ${gainOrLoss.amount.toStringAsFixed(2)}'
                  : 'قيمة دفترية: ${asset.netBookValue.amount.toStringAsFixed(2)}'),
              createdAt: DateTime.now(),
              createdBy: params.disposedBy,
            );

            await _movementRepository.create(movement);

            // تسجيل في Audit Log
            await _auditLog.log(
              action: isSale ? 'SALE_FIXED_ASSET' : 'DISPOSE_FIXED_ASSET',
              entityType: 'FixedAsset',
              entityId: savedAsset.id.value,
              userId: params.disposedBy,
              details: {
                'code': asset.code,
                'name': asset.name,
                'netBookValue': asset.netBookValue.amount.toString(),
                if (isSale) 'salePrice': params.salePrice!.amount.toString(),
                if (gainOrLoss != null) 'gainOrLoss': gainOrLoss.amount.toString(),
              },
            );

            return Right(savedAsset);
          },
        );
      },
    );
  }
}
