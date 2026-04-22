import 'package:dartz/dartz.dart';
import 'package:foundation/foundation.dart';
import '../../../domain/domain.dart';

/// معلمات تحديث مستهلك
class UpdateConsumableParams {
  final UniqueId id;
  final String? name;
  final UniqueId? categoryId;
  final Quantity? unitOfMeasure;
  final String? location;
  final String? notes;
  final bool? isActive;
  final String updatedBy;

  const UpdateConsumableParams({
    required this.id,
    this.name,
    this.categoryId,
    this.unitOfMeasure,
    this.location,
    this.notes,
    this.isActive,
    required this.updatedBy,
  });
}

/// حالة استخدام: تحديث مستهلك
class UpdateConsumableUseCase {
  final ConsumableRepository _repository;

  UpdateConsumableUseCase({required ConsumableRepository repository})
      : _repository = repository;

  Future<Either<AssetFailure, ConsumableItem>> call(UpdateConsumableParams params) async {
    final existingResult = await _repository.getById(params.id);
    
    return existingResult.fold(
      (failure) => Left(failure),
      (existingItem) async {
        final updatedItem = existingItem.copyWith(
          name: params.name,
          categoryId: params.categoryId,
          unitOfMeasure: params.unitOfMeasure,
          location: params.location,
          notes: params.notes,
          isActive: params.isActive,
          updatedAt: DateTime.now(),
        );

        return await _repository.update(updatedItem);
      },
    );
  }
}

/// معلمات حذف مستهلك
class DeleteConsumableParams {
  final UniqueId id;
  final String deletedBy;
  final String? reason;

  const DeleteConsumableParams({
    required this.id,
    required this.deletedBy,
    this.reason,
  });
}

/// حالة استخدام: حذف مستهلك
class DeleteConsumableUseCase {
  final ConsumableRepository _repository;
  final AssetMovementRepository _movementRepository;

  DeleteConsumableUseCase({
    required ConsumableRepository repository,
    required AssetMovementRepository movementRepository,
  })  : _repository = repository,
        _movementRepository = movementRepository;

  Future<Either<AssetFailure, Unit>> call(DeleteConsumableParams params) async {
    final existingResult = await _repository.getById(params.id);
    
    return existingResult.fold(
      (failure) => Left(failure),
      (item) async {
        // التحقق من عدم وجود مخزون قبل الحذف (سياسة)
        if (item.quantityOnHand.value > 0) {
          return Left(const InvalidConsumableFailure(
            'لا يمكن حذف مستهلك يحتوي على مخزون. قم بصرف أو استهلاك الكمية أولاً.',
          ));
        }

        // حذف الحركات المرتبطة
        final movementsResult = await _movementRepository.getByAssetId(params.id);
        movementsResult.fold(
          (failure) => null,
          (movements) async {
            for (final movement in movements) {
              await _movementRepository.delete(movement.id);
            }
          },
        );

        return await _repository.delete(params.id);
      },
    );
  }
}
