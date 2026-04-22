import 'package:dartz/dartz.dart';
import 'package:foundation/foundation.dart';
import '../../../domain/domain.dart';

/// معلمات البحث عن الأصول الثابتة
class GetFixedAssetsParams {
  final AssetStatus? status;
  final UniqueId? categoryId;
  final String? location;
  final bool? isActive;
  final DateTime? fromDate;
  final DateTime? toDate;
  final String? searchQuery;

  const GetFixedAssetsParams({
    this.status,
    this.categoryId,
    this.location,
    this.isActive,
    this.fromDate,
    this.toDate,
    this.searchQuery,
  });
}

/// حالة استخدام: الحصول على قائمة الأصول الثابتة
class GetFixedAssetsUseCase {
  final FixedAssetRepository _repository;

  GetFixedAssetsUseCase({required FixedAssetRepository repository})
      : _repository = repository;

  Future<Either<AssetFailure, List<FixedAsset>>> call(GetFixedAssetsParams params) async {
    if (params.searchQuery != null && params.searchQuery!.isNotEmpty) {
      return await _repository.search(params.searchQuery!);
    }

    return await _repository.getAll(
      status: params.status,
      categoryId: params.categoryId,
      location: params.location,
      isActive: params.isActive,
      fromDate: params.fromDate,
      toDate: params.toDate,
    );
  }
}

/// حالة استخدام: الحصول على أصل ثابت بواسطة المعرف
class GetFixedAssetByIdUseCase {
  final FixedAssetRepository _repository;

  GetFixedAssetByIdUseCase({required FixedAssetRepository repository})
      : _repository = repository;

  Future<Either<AssetFailure, FixedAsset>> call(UniqueId id) async {
    return await _repository.getById(id);
  }
}

/// حالة استخدام: الحصول على ملخص الأصول الثابتة
class GetFixedAssetsSummaryUseCase {
  final FixedAssetRepository _repository;

  GetFixedAssetsSummaryUseCase({required FixedAssetRepository repository})
      : _repository = repository;

  Future<Either<AssetFailure, FixedAssetsSummary>> call() async {
    return await _repository.getSummary();
  }
}
