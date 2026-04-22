import 'package:equatable/equatable.dart';
import '../../../domain/domain.dart';

/// حالات شاشة الأصول الثابتة
abstract class FixedAssetsState extends Equatable {
  const FixedAssetsState();
  
  @override
  List<Object?> get props => [];
}

/// الحالة الأولية
class FixedAssetsInitial extends FixedAssetsState {
  const FixedAssetsInitial();
}

/// جاري التحميل
class FixedAssetsLoading extends FixedAssetsState {
  const FixedAssetsLoading();
}

/// تم التحميل بنجاح
class FixedAssetsLoaded extends FixedAssetsState {
  final List<FixedAsset> assets;
  final FixedAssetsSummary? summary;
  final AssetStatus? filterStatus;
  final String? searchQuery;

  const FixedAssetsLoaded({
    required this.assets,
    this.summary,
    this.filterStatus,
    this.searchQuery,
  });

  FixedAssetsLoaded copyWith({
    List<FixedAsset>? assets,
    FixedAssetsSummary? summary,
    AssetStatus? filterStatus,
    String? searchQuery,
  }) {
    return FixedAssetsLoaded(
      assets: assets ?? this.assets,
      summary: summary ?? this.summary,
      filterStatus: filterStatus ?? this.filterStatus,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [assets, summary, filterStatus, searchQuery];
}

/// حالة التعديل
class FixedAssetEditing extends FixedAssetsState {
  final FixedAsset? asset; // null if creating new
  final bool isLoading;
  final String? error;

  const FixedAssetEditing({
    this.asset,
    this.isLoading = false,
    this.error,
  });

  FixedAssetEditing copyWith({
    FixedAsset? asset,
    bool? isLoading,
    String? error,
  }) {
    return FixedAssetEditing(
      asset: asset ?? this.asset,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [asset, isLoading, error];
}

/// جاري الحفظ
class FixedAssetSaving extends FixedAssetsState {
  const FixedAssetSaving();
}

/// تمت العملية بنجاح
class FixedAssetSuccess extends FixedAssetsState {
  final String message;
  final FixedAsset? asset;

  const FixedAssetSuccess({
    required this.message,
    this.asset,
  });

  @override
  List<Object?> get props => [message, asset];
}

/// حالة الخطأ
class FixedAssetError extends FixedAssetsState {
  final String message;

  const FixedAssetError(this.message);

  @override
  List<Object?> get props => [message];
}
