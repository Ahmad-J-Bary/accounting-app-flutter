import 'package:dartz/dartz.dart';
import 'package:foundation/foundation.dart';
import '../../../domain/domain.dart';

/// معلمات البحث عن المستهلكات
class GetConsumablesParams {
  final ConsumableStatus? status;
  final UniqueId? categoryId;
  final String? location;
  final bool? isActive;
  final bool? lowStock;
  final String? searchQuery;

  const GetConsumablesParams({
    this.status,
    this.categoryId,
    this.location,
    this.isActive,
    this.lowStock,
    this.searchQuery,
  });
}

/// حالة استخدام: الحصول على قائمة المستهلكات
class GetConsumablesUseCase {
  final ConsumableRepository _repository;

  GetConsumablesUseCase({required ConsumableRepository repository})
      : _repository = repository;

  Future<Either<AssetFailure, List<ConsumableItem>>> call(GetConsumablesParams params) async {
    if (params.searchQuery != null && params.searchQuery!.isNotEmpty) {
      return await _repository.search(params.searchQuery!);
    }

    return await _repository.getAll(
      status: params.status,
      categoryId: params.categoryId,
      location: params.location,
      isActive: params.isActive,
      lowStock: params.lowStock,
    );
  }
}

/// حالة استخدام: الحصول على مستهلك بواسطة المعرف
class GetConsumableByIdUseCase {
  final ConsumableRepository _repository;

  GetConsumableByIdUseCase({required ConsumableRepository repository})
      : _repository = repository;

  Future<Either<AssetFailure, ConsumableItem>> call(UniqueId id) async {
    return await _repository.getById(id);
  }
}

/// حالة استخدام: الحصول على ملخص المستهلكات
class GetConsumablesSummaryUseCase {
  final ConsumableRepository _repository;

  GetConsumablesSummaryUseCase({required ConsumableRepository repository})
      : _repository = repository;

  Future<Either<AssetFailure, ConsumablesSummary>> call() async {
    return await _repository.getSummary();
  }
}
