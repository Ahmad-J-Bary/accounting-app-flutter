import 'package:dartz/dartz.dart';
import 'package:foundation/foundation.dart';
import '../../../domain/domain.dart';

/// معلمات حذف أصل ثابت
class DeleteFixedAssetParams {
  final UniqueId id;
  final String deletedBy;
  final String? reason;

  const DeleteFixedAssetParams({
    required this.id,
    required this.deletedBy,
    this.reason,
  });
}

/// حالة استخدام: حذف أصل ثابت
class DeleteFixedAssetUseCase {
  final FixedAssetRepository _repository;
  final AssetMovementRepository _movementRepository;
  final AuditLogService _auditLog;

  DeleteFixedAssetUseCase({
    required FixedAssetRepository repository,
    required AssetMovementRepository movementRepository,
    required AuditLogService auditLog,
  })  : _repository = repository,
        _movementRepository = movementRepository,
        _auditLog = auditLog;

  Future<Either<AssetFailure, Unit>> call(DeleteFixedAssetParams params) async {
    // الحصول على الأصل
    final existingResult = await _repository.getById(params.id);
    
    return existingResult.fold(
      (failure) => Left(failure),
      (asset) async {
        // التحقق من أن الأصل غير مرحّل (يمكن تعديل هذا الشرط)
        if (asset.journalEntryId != null) {
          return Left(AssetLockedFailure(
            assetId: params.id,
            reason: 'لا يمكن حذف أصل تم ترحيله محاسبياً',
          ));
        }

        // حذف الحركات المرتبطة
        final movementsResult = await _movementRepository.getByAssetId(params.id);
        movementsResult.fold(
          (failure) => null, // تجاهل خطأ الحركات
          (movements) async {
            for (final movement in movements) {
              await _movementRepository.delete(movement.id);
            }
          },
        );

        // حذف الأصل
        final result = await _repository.delete(params.id);

        return result.fold(
          (failure) => Left(failure),
          (_) async {
            // تسجيل في Audit Log
            await _auditLog.log(
              action: 'DELETE_FIXED_ASSET',
              entityType: 'FixedAsset',
              entityId: params.id.value,
              userId: params.deletedBy,
              details: {
                'code': asset.code,
                'name': asset.name,
                'reason': params.reason,
              },
            );
            return const Right(unit);
          },
        );
      },
    );
  }
}
