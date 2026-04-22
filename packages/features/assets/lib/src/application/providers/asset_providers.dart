import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/domain.dart';
import '../usecases/usecases.dart';

/// Provider للـ Audit Log Service
final auditLogServiceProvider = Provider<AuditLogService>((ref) {
  // TODO: Implement actual AuditLogService
  return _PlaceholderAuditLogService();
});

/// Repository Providers
final fixedAssetRepositoryProvider = Provider<FixedAssetRepository>((ref) {
  return FixedAssetRepositoryImpl();
});

final consumableRepositoryProvider = Provider<ConsumableRepository>((ref) {
  return ConsumableRepositoryImpl();
});

final assetMovementRepositoryProvider = Provider<AssetMovementRepository>((ref) {
  return AssetMovementRepositoryImpl();
});

/// خدمة Audit Log مؤقتة
class _PlaceholderAuditLogService implements AuditLogService {
  @override
  Future<void> log({
    required String action,
    required String entityType,
    required String entityId,
    required String userId,
    Map<String, dynamic>? details,
  }) async {
    // TODO: Implement actual audit logging to database
    print('[AUDIT] $action - $entityType:$entityId by $userId');
    if (details != null) {
      print('  Details: $details');
    }
  }
}

/// Fixed Assets Use Cases Providers
final createFixedAssetUseCaseProvider = Provider<CreateFixedAssetUseCase>((ref) {
  return CreateFixedAssetUseCase(
    repository: ref.watch(fixedAssetRepositoryProvider),
    movementRepository: ref.watch(assetMovementRepositoryProvider),
    auditLog: ref.watch(auditLogServiceProvider),
  );
});

final getFixedAssetsUseCaseProvider = Provider<GetFixedAssetsUseCase>((ref) {
  return GetFixedAssetsUseCase(
    repository: ref.watch(fixedAssetRepositoryProvider),
  );
});

final getFixedAssetByIdUseCaseProvider = Provider<GetFixedAssetByIdUseCase>((ref) {
  return GetFixedAssetByIdUseCase(
    repository: ref.watch(fixedAssetRepositoryProvider),
  );
});

final getFixedAssetsSummaryUseCaseProvider = Provider<GetFixedAssetsSummaryUseCase>((ref) {
  return GetFixedAssetsSummaryUseCase(
    repository: ref.watch(fixedAssetRepositoryProvider),
  );
});

final updateFixedAssetUseCaseProvider = Provider<UpdateFixedAssetUseCase>((ref) {
  return UpdateFixedAssetUseCase(
    repository: ref.watch(fixedAssetRepositoryProvider),
    auditLog: ref.watch(auditLogServiceProvider),
  );
});

final deleteFixedAssetUseCaseProvider = Provider<DeleteFixedAssetUseCase>((ref) {
  return DeleteFixedAssetUseCase(
    repository: ref.watch(fixedAssetRepositoryProvider),
    movementRepository: ref.watch(assetMovementRepositoryProvider),
    auditLog: ref.watch(auditLogServiceProvider),
  );
});

final disposeFixedAssetUseCaseProvider = Provider<DisposeFixedAssetUseCase>((ref) {
  return DisposeFixedAssetUseCase(
    repository: ref.watch(fixedAssetRepositoryProvider),
    movementRepository: ref.watch(assetMovementRepositoryProvider),
    auditLog: ref.watch(auditLogServiceProvider),
  );
});

final generateDepreciationScheduleUseCaseProvider = Provider<GenerateDepreciationScheduleUseCase>((ref) {
  return GenerateDepreciationScheduleUseCase(
    repository: ref.watch(fixedAssetRepositoryProvider),
    auditLog: ref.watch(auditLogServiceProvider),
  );
});

final postMonthlyDepreciationUseCaseProvider = Provider<PostMonthlyDepreciationUseCase>((ref) {
  return PostMonthlyDepreciationUseCase(
    repository: ref.watch(fixedAssetRepositoryProvider),
    movementRepository: ref.watch(assetMovementRepositoryProvider),
    auditLog: ref.watch(auditLogServiceProvider),
  );
});

/// Consumables Use Cases Providers
final createConsumableUseCaseProvider = Provider<CreateConsumableUseCase>((ref) {
  return CreateConsumableUseCase(
    repository: ref.watch(consumableRepositoryProvider),
    movementRepository: ref.watch(assetMovementRepositoryProvider),
  );
});

final getConsumablesUseCaseProvider = Provider<GetConsumablesUseCase>((ref) {
  return GetConsumablesUseCase(
    repository: ref.watch(consumableRepositoryProvider),
  );
});

final getConsumableByIdUseCaseProvider = Provider<GetConsumableByIdUseCase>((ref) {
  return GetConsumableByIdUseCase(
    repository: ref.watch(consumableRepositoryProvider),
  );
});

final getConsumablesSummaryUseCaseProvider = Provider<GetConsumablesSummaryUseCase>((ref) {
  return GetConsumablesSummaryUseCase(
    repository: ref.watch(consumableRepositoryProvider),
  );
});

final updateConsumableUseCaseProvider = Provider<UpdateConsumableUseCase>((ref) {
  return UpdateConsumableUseCase(
    repository: ref.watch(consumableRepositoryProvider),
  );
});

final deleteConsumableUseCaseProvider = Provider<DeleteConsumableUseCase>((ref) {
  return DeleteConsumableUseCase(
    repository: ref.watch(consumableRepositoryProvider),
    movementRepository: ref.watch(assetMovementRepositoryProvider),
  );
});

final issueConsumableUseCaseProvider = Provider<IssueConsumableUseCase>((ref) {
  return IssueConsumableUseCase(
    repository: ref.watch(consumableRepositoryProvider),
    movementRepository: ref.watch(assetMovementRepositoryProvider),
  );
});

final receiveConsumableUseCaseProvider = Provider<ReceiveConsumableUseCase>((ref) {
  return ReceiveConsumableUseCase(
    repository: ref.watch(consumableRepositoryProvider),
    movementRepository: ref.watch(assetMovementRepositoryProvider),
  );
});

final adjustConsumableStockUseCaseProvider = Provider<AdjustConsumableStockUseCase>((ref) {
  return AdjustConsumableStockUseCase(
    repository: ref.watch(consumableRepositoryProvider),
    movementRepository: ref.watch(assetMovementRepositoryProvider),
  );
});
