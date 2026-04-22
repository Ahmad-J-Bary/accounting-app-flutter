import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../application/application.dart';
import '../../../domain/domain.dart';
import 'fixed_assets_state.dart';

/// مدير حالة الأصول الثابتة (StateNotifier)
class FixedAssetsNotifier extends StateNotifier<FixedAssetsState> {
  final GetFixedAssetsUseCase _getAssetsUseCase;
  final GetFixedAssetsSummaryUseCase _getSummaryUseCase;
  final CreateFixedAssetUseCase _createAssetUseCase;
  final UpdateFixedAssetUseCase _updateAssetUseCase;
  final DeleteFixedAssetUseCase _deleteAssetUseCase;
  final DisposeFixedAssetUseCase _disposeAssetUseCase;
  final PostMonthlyDepreciationUseCase _postDepreciationUseCase;

  FixedAssetsNotifier({
    required GetFixedAssetsUseCase getAssetsUseCase,
    required GetFixedAssetsSummaryUseCase getSummaryUseCase,
    required CreateFixedAssetUseCase createAssetUseCase,
    required UpdateFixedAssetUseCase updateAssetUseCase,
    required DeleteFixedAssetUseCase deleteAssetUseCase,
    required DisposeFixedAssetUseCase disposeAssetUseCase,
    required PostMonthlyDepreciationUseCase postDepreciationUseCase,
  })  : _getAssetsUseCase = getAssetsUseCase,
        _getSummaryUseCase = getSummaryUseCase,
        _createAssetUseCase = createAssetUseCase,
        _updateAssetUseCase = updateAssetUseCase,
        _deleteAssetUseCase = deleteAssetUseCase,
        _disposeAssetUseCase = disposeAssetUseCase,
        _postDepreciationUseCase = postDepreciationUseCase,
        super(const FixedAssetsInitial());

  /// تحميل قائمة الأصول
  Future<void> loadAssets({
    AssetStatus? status,
    String? searchQuery,
  }) async {
    state = const FixedAssetsLoading();

    final params = GetFixedAssetsParams(
      status: status,
      searchQuery: searchQuery,
    );

    final result = await _getAssetsUseCase(params);
    final summaryResult = await _getSummaryUseCase();

    result.fold(
      (failure) => state = FixedAssetError(failure.toString()),
      (assets) {
        summaryResult.fold(
          (failure) => state = FixedAssetError(failure.toString()),
          (summary) => state = FixedAssetsLoaded(
            assets: assets,
            summary: summary,
            filterStatus: status,
            searchQuery: searchQuery,
          ),
        );
      },
    );
  }

  /// البحث في الأصول
  Future<void> searchAssets(String query) async {
    if (state is FixedAssetsLoaded) {
      final currentState = state as FixedAssetsLoaded;
      await loadAssets(
        status: currentState.filterStatus,
        searchQuery: query.isEmpty ? null : query,
      );
    } else {
      await loadAssets(searchQuery: query.isEmpty ? null : query);
    }
  }

  /// تصفية حسب الحالة
  Future<void> filterByStatus(AssetStatus? status) async {
    if (state is FixedAssetsLoaded) {
      final currentState = state as FixedAssetsLoaded;
      await loadAssets(
        status: status,
        searchQuery: currentState.searchQuery,
      );
    } else {
      await loadAssets(status: status);
    }
  }

  /// فتح نموذج إضافة/تعديل
  void openEditForm(FixedAsset? asset) {
    state = FixedAssetEditing(asset: asset);
  }

  /// إنشاء أصل جديد
  Future<void> createAsset(CreateFixedAssetParams params) async {
    state = const FixedAssetSaving();

    final result = await _createAssetUseCase(params);

    result.fold(
      (failure) => state = FixedAssetError(failure.toString()),
      (asset) {
        state = FixedAssetSuccess(
          message: 'تم إضافة الأصل ${asset.name} بنجاح',
          asset: asset,
        );
        // إعادة تحميل القائمة
        loadAssets();
      },
    );
  }

  /// تحديث أصل
  Future<void> updateAsset(UpdateFixedAssetParams params) async {
    state = const FixedAssetSaving();

    final result = await _updateAssetUseCase(params);

    result.fold(
      (failure) => state = FixedAssetError(failure.toString()),
      (asset) {
        state = FixedAssetSuccess(
          message: 'تم تحديث الأصل ${asset.name} بنجاح',
          asset: asset,
        );
        loadAssets();
      },
    );
  }

  /// حذف أصل
  Future<void> deleteAsset(UniqueId id, String deletedBy) async {
    final params = DeleteFixedAssetParams(
      id: id,
      deletedBy: deletedBy,
    );

    final result = await _deleteAssetUseCase(params);

    result.fold(
      (failure) => state = FixedAssetError(failure.toString()),
      (_) {
        state = const FixedAssetSuccess(message: 'تم حذف الأصل بنجاح');
        loadAssets();
      },
    );
  }

  /// استبعاد/بيع أصل
  Future<void> disposeAsset(DisposeFixedAssetParams params) async {
    state = const FixedAssetsLoading();

    final result = await _disposeAssetUseCase(params);

    result.fold(
      (failure) => state = FixedAssetError(failure.toString()),
      (asset) {
        state = FixedAssetSuccess(
          message: asset.status == AssetStatus.sold
              ? 'تم بيع الأصل ${asset.name} بنجاح'
              : 'تم استبعاد الأصل ${asset.name} بنجاح',
          asset: asset,
        );
        loadAssets();
      },
    );
  }

  /// تسجيل اهلاك شهري
  Future<void> postDepreciation(
    UniqueId assetId,
    DateTime postingDate,
    String postedBy,
  ) async {
    state = const FixedAssetsLoading();

    final params = PostMonthlyDepreciationParams(
      fixedAssetId: assetId,
      postingDate: postingDate,
      postedBy: postedBy,
    );

    final result = await _postDepreciationUseCase(params);

    result.fold(
      (failure) => state = FixedAssetError(failure.toString()),
      (asset) {
        state = FixedAssetSuccess(
          message: 'تم تسجيل الاهلاك الشهري للأصل ${asset.name}',
          asset: asset,
        );
        loadAssets();
      },
    );
  }

  /// مسح حالة الخطأ
  void clearError() {
    if (state is FixedAssetsLoaded) {
      final currentState = state as FixedAssetsLoaded;
      state = currentState.copyWith();
    } else {
      state = const FixedAssetsInitial();
    }
  }

  /// إعادة تحميل
  void refresh() {
    if (state is FixedAssetsLoaded) {
      final currentState = state as FixedAssetsLoaded;
      loadAssets(
        status: currentState.filterStatus,
        searchQuery: currentState.searchQuery,
      );
    } else {
      loadAssets();
    }
  }
}

/// Provider للمدير
final fixedAssetsNotifierProvider =
    StateNotifierProvider<FixedAssetsNotifier, FixedAssetsState>((ref) {
  return FixedAssetsNotifier(
    getAssetsUseCase: ref.watch(getFixedAssetsUseCaseProvider),
    getSummaryUseCase: ref.watch(getFixedAssetsSummaryUseCaseProvider),
    createAssetUseCase: ref.watch(createFixedAssetUseCaseProvider),
    updateAssetUseCase: ref.watch(updateFixedAssetUseCaseProvider),
    deleteAssetUseCase: ref.watch(deleteFixedAssetUseCaseProvider),
    disposeAssetUseCase: ref.watch(disposeFixedAssetUseCaseProvider),
    postDepreciationUseCase: ref.watch(postMonthlyDepreciationUseCaseProvider),
  );
});
