import 'package:dartz/dartz.dart';
import 'package:foundation/foundation.dart';
import '../../../domain/domain.dart';

/// معلمات إنشاء مادة مستهلكية
class CreateConsumableParams {
  final String code;
  final String name;
  final UniqueId categoryId;
  final Quantity initialQuantity;
  final Quantity unitOfMeasure;
  final Money unitCost;
  final Currency currency;
  final MoneyFxRate fxRate;
  final String? location;
  final String? notes;
  final String createdBy;

  const CreateConsumableParams({
    required this.code,
    required this.name,
    required this.categoryId,
    required this.initialQuantity,
    required this.unitOfMeasure,
    required this.unitCost,
    required this.currency,
    required this.fxRate,
    this.location,
    this.notes,
    required this.createdBy,
  });
}

/// حالة استخدام: إنشاء مادة مستهلكية جديدة
class CreateConsumableUseCase {
  final ConsumableRepository _repository;
  final AssetMovementRepository _movementRepository;

  CreateConsumableUseCase({
    required ConsumableRepository repository,
    required AssetMovementRepository movementRepository,
  })  : _repository = repository,
        _movementRepository = movementRepository;

  Future<Either<AssetFailure, ConsumableItem>> call(CreateConsumableParams params) async {
    final now = DateTime.now();
    final totalCost = params.unitCost.multiply(params.initialQuantity.value);

    final item = ConsumableItem(
      id: UniqueId.generate(),
      code: params.code,
      name: params.name,
      categoryId: params.categoryId,
      quantityOnHand: params.initialQuantity,
      unitOfMeasure: params.unitOfMeasure,
      unitCost: params.unitCost,
      currency: params.currency,
      fxRate: params.fxRate,
      totalCost: totalCost,
      status: ConsumableStatus.inStock,
      location: params.location,
      notes: params.notes,
      createdAt: now,
      updatedAt: now,
    );

    // التحقق من السياسات
    final validationResult = ConsumablePolicy.validateCreation(item);
    if (validationResult.isLeft()) {
      return Left((validationResult as Left).value);
    }

    // حفظ المستهلك
    final result = await _repository.create(item);

    return result.fold(
      (failure) => Left(failure),
      (createdItem) async {
        // تسجيل حركة الاستلام
        final movement = AssetMovement(
          id: UniqueId.generate(),
          assetId: createdItem.id,
          assetType: AssetType.consumable,
          movementType: AssetMovementType.acquisition,
          date: now,
          quantity: params.initialQuantity,
          amount: totalCost,
          currency: params.currency,
          fxRate: params.fxRate,
          description: 'إضافة مستهلك: ${params.name}',
          referenceNo: params.code,
          createdAt: now,
          createdBy: params.createdBy,
        );

        await _movementRepository.create(movement);

        return Right(createdItem);
      },
    );
  }
}
