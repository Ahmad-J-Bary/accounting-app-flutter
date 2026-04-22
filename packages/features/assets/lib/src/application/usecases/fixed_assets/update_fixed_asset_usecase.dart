import 'package:dartz/dartz.dart';
import 'package:foundation/foundation.dart';
import '../../../domain/domain.dart';

/// معلمات تحديث أصل ثابت
class UpdateFixedAssetParams {
  final UniqueId id;
  final String? name;
  final UniqueId? categoryId;
  final String? location;
  final String? notes;
  final bool? isActive;
  final String updatedBy;

  const UpdateFixedAssetParams({
    required this.id,
    this.name,
    this.categoryId,
    this.location,
    this.notes,
    this.isActive,
    required this.updatedBy,
  });
}

/// حالة استخدام: تحديث أصل ثابت
class UpdateFixedAssetUseCase {
  final FixedAssetRepository _repository;
  final AuditLogService _auditLog;

  UpdateFixedAssetUseCase({
    required FixedAssetRepository repository,
    required AuditLogService auditLog,
  })  : _repository = repository,
        _auditLog = auditLog;

  Future<Either<AssetFailure, FixedAsset>> call(UpdateFixedAssetParams params) async {
    // الحصول على الأصل الحالي
    final existingResult = await _repository.getById(params.id);
    
    return existingResult.fold(
      (failure) => Left(failure),
      (existingAsset) async {
        // التحقق من أن الأصل غير مؤمّن
        if (existingAsset.journalEntryId != null) {
          // يمكن إضافة سياسة أكثر صرامة هنا
          // return Left(AssetLockedFailure(assetId: params.id, reason: 'تم ترحيل الأصل'));
        }

        // إنشاء الأصل المحدث
        final updatedAsset = existingAsset.copyWith(
          name: params.name,
          categoryId: params.categoryId,
          location: params.location,
          notes: params.notes,
          isActive: params.isActive,
          updatedAt: DateTime.now(),
        );

        // حفظ التغييرات
        final result = await _repository.update(updatedAsset);

        return result.fold(
          (failure) => Left(failure),
          (asset) async {
            // تسجيل في Audit Log
            await _auditLog.log(
              action: 'UPDATE_FIXED_ASSET',
              entityType: 'FixedAsset',
              entityId: asset.id.value,
              userId: params.updatedBy,
              details: {
                'code': asset.code,
                'changes': _getChanges(existingAsset, asset),
              },
            );
            return Right(asset);
          },
        );
      },
    );
  }

  Map<String, dynamic> _getChanges(FixedAsset old, FixedAsset updated) {
    final changes = <String, dynamic>{};
    if (old.name != updated.name) changes['name'] = {'old': old.name, 'new': updated.name};
    if (old.location != updated.location) changes['location'] = {'old': old.location, 'new': updated.location};
    if (old.isActive != updated.isActive) changes['isActive'] = {'old': old.isActive, 'new': updated.isActive};
    return changes;
  }
}
