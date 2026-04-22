import 'package:dartz/dartz.dart';
import 'package:foundation/foundation.dart';
import '../../../domain/domain.dart';

/// معلمات صرف مستهلك
class IssueConsumableParams {
  final UniqueId consumableId;
  final Quantity quantity;
  final DateTime issueDate;
  final String? department; // الجهة المستفيدة
  final String? authorizedBy;
  final String? referenceNo;
  final String? notes;
  final String issuedBy;

  const IssueConsumableParams({
    required this.consumableId,
    required this.quantity,
    required this.issueDate,
    this.department,
    this.authorizedBy,
    this.referenceNo,
    this.notes,
    required this.issuedBy,
  });
}

/// حالة استخدام: صرف مستهلك
class IssueConsumableUseCase {
  final ConsumableRepository _repository;
  final AssetMovementRepository _movementRepository;

  IssueConsumableUseCase({
    required ConsumableRepository repository,
    required AssetMovementRepository movementRepository,
  })  : _repository = repository,
        _movementRepository = movementRepository;

  Future<Either<AssetFailure, ConsumableItem>> call(IssueConsumableParams params) async {
    final itemResult = await _repository.getById(params.consumableId);
    
    return itemResult.fold(
      (failure) => Left(failure),
      (item) async {
        // التحقق من السياسات
        final validationResult = ConsumablePolicy.validateIssue(item, params.quantity);
        if (validationResult.isLeft()) {
          return Left((validationResult as Left).value);
        }

        // تنفيذ الصرف
        final updatedItem = item.issue(params.quantity);
        final saveResult = await _repository.update(updatedItem);

        return saveResult.fold(
          (failure) => Left(failure),
          (savedItem) async {
            // تسجيل حركة الصرف
            final cost = item.unitCost.multiply(params.quantity.value);
            final movement = AssetMovement(
              id: UniqueId.generate(),
              assetId: savedItem.id,
              assetType: AssetType.consumable,
              movementType: AssetMovementType.issue,
              date: params.issueDate,
              quantity: params.quantity,
              amount: cost,
              currency: item.currency,
              fxRate: item.fxRate,
              description: 'صرف ${params.quantity.value} ${item.unitOfMeasure.unit} من ${item.name}'
                  '${params.department != null ? ' لـ ${params.department}' : ''}',
              referenceNo: params.referenceNo ?? 'ISS-${item.code}-${DateTime.now().millisecondsSinceEpoch}',
              notes: params.notes,
              createdAt: DateTime.now(),
              createdBy: params.issuedBy,
            );

            await _movementRepository.create(movement);
            return Right(savedItem);
          },
        );
      },
    );
  }
}

/// معلمات استلام مخزون
class ReceiveConsumableParams {
  final UniqueId consumableId;
  final Quantity quantity;
  final Money unitCost;
  final Currency currency;
  final MoneyFxRate fxRate;
  final DateTime receiveDate;
  final String? supplierId;
  final String? supplierName;
  final String? referenceNo;
  final String? notes;
  final String receivedBy;

  const ReceiveConsumableParams({
    required this.consumableId,
    required this.quantity,
    required this.unitCost,
    required this.currency,
    required this.fxRate,
    required this.receiveDate,
    this.supplierId,
    this.supplierName,
    this.referenceNo,
    this.notes,
    required this.receivedBy,
  });
}

/// حالة استخدام: استلام مخزون
class ReceiveConsumableUseCase {
  final ConsumableRepository _repository;
  final AssetMovementRepository _movementRepository;

  ReceiveConsumableUseCase({
    required ConsumableRepository repository,
    required AssetMovementRepository movementRepository,
  })  : _repository = repository,
        _movementRepository = movementRepository;

  Future<Either<AssetFailure, ConsumableItem>> call(ReceiveConsumableParams params) async {
    final itemResult = await _repository.getById(params.consumableId);
    
    return itemResult.fold(
      (failure) => Left(failure),
      (item) async {
        // التحقق من السياسات
        final validationResult = ConsumablePolicy.validateReceipt(
          item,
          params.quantity,
          params.unitCost,
        );
        if (validationResult.isLeft()) {
          return Left((validationResult as Left).value);
        }

        // تنفيذ الاستلام
        final updatedItem = item.receive(params.quantity, params.unitCost);
        final saveResult = await _repository.update(updatedItem);

        return saveResult.fold(
          (failure) => Left(failure),
          (savedItem) async {
            // تسجيل حركة الاستلام
            final totalCost = params.unitCost.multiply(params.quantity.value);
            final movement = AssetMovement(
              id: UniqueId.generate(),
              assetId: savedItem.id,
              assetType: AssetType.consumable,
              movementType: AssetMovementType.acquisition,
              date: params.receiveDate,
              quantity: params.quantity,
              amount: totalCost,
              currency: params.currency,
              fxRate: params.fxRate,
              description: 'استلام ${params.quantity.value} ${item.unitOfMeasure.unit} من ${item.name}'
                  '${params.supplierName != null ? ' من ${params.supplierName}' : ''}',
              referenceNo: params.referenceNo ?? 'REC-${item.code}-${DateTime.now().millisecondsSinceEpoch}',
              partnerId: params.supplierId != null ? UniqueId.fromUniqueString(params.supplierId!) : null,
              partnerName: params.supplierName,
              notes: params.notes,
              createdAt: DateTime.now(),
              createdBy: params.receivedBy,
            );

            await _movementRepository.create(movement);
            return Right(savedItem);
          },
        );
      },
    );
  }
}

/// معلمات تسوية المخزون
class AdjustConsumableStockParams {
  final UniqueId consumableId;
  final Quantity newQuantity;
  final String reason;
  final DateTime adjustmentDate;
  final String? referenceNo;
  final String adjustedBy;

  const AdjustConsumableStockParams({
    required this.consumableId,
    required this.newQuantity,
    required this.reason,
    required this.adjustmentDate,
    this.referenceNo,
    required this.adjustedBy,
  });
}

/// حالة استخدام: تسوية مخزون
class AdjustConsumableStockUseCase {
  final ConsumableRepository _repository;
  final AssetMovementRepository _movementRepository;

  AdjustConsumableStockUseCase({
    required ConsumableRepository repository,
    required AssetMovementRepository movementRepository,
  })  : _repository = repository,
        _movementRepository = movementRepository;

  Future<Either<AssetFailure, ConsumableItem>> call(AdjustConsumableStockParams params) async {
    final itemResult = await _repository.getById(params.consumableId);
    
    return itemResult.fold(
      (failure) => Left(failure),
      (item) async {
        // التحقق من السياسات
        final validationResult = ConsumablePolicy.validateAdjustment(
          item,
          params.newQuantity,
          params.reason,
        );
        if (validationResult.isLeft()) {
          return Left((validationResult as Left).value);
        }

        // حساب الفرق
        final difference = params.newQuantity.value - item.quantityOnHand.value;
        final isPositive = difference > 0;
        final absDifference = difference.abs();
        
        // تنفيذ التسوية عبر المستودع
        final saveResult = await _repository.adjustStock(
          params.consumableId,
          params.newQuantity,
          params.reason,
          params.adjustmentDate,
        );

        return saveResult.fold(
          (failure) => Left(failure),
          (savedItem) async {
            // تسجيل حركة التسوية
            if (absDifference > 0) {
              final movementType = isPositive
                  ? AssetMovementType.adjustment // زيادة
                  : AssetMovementType.adjustment; // نقصان (يمكن تفريقهما لاحقاً)
              
              final movement = AssetMovement(
                id: UniqueId.generate(),
                assetId: savedItem.id,
                assetType: AssetType.consumable,
                movementType: movementType,
                date: params.adjustmentDate,
                quantity: Quantity(absDifference, item.unitOfMeasure.unit),
                amount: item.unitCost.multiply(absDifference),
                currency: item.currency,
                fxRate: item.fxRate,
                description: 'تسوية مخزون: ${isPositive ? '+' : ''}$difference ${item.unitOfMeasure.unit} - ${params.reason}',
                referenceNo: params.referenceNo ?? 'ADJ-${item.code}-${DateTime.now().millisecondsSinceEpoch}',
                notes: params.reason,
                createdAt: DateTime.now(),
                createdBy: params.adjustedBy,
              );

              await _movementRepository.create(movement);
            }
            return Right(savedItem);
          },
        );
      },
    );
  }
}
