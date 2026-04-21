import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:platform/local_db/local_db.dart';
import 'package:audit_log/audit_log.dart';

final auditLogRepositoryProvider = Provider<AuditLogRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return AuditLogRepositoryImpl(database);
});

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase.instance;
});

final logAuditEventUseCaseProvider = Provider<LogAuditEventUseCase>((ref) {
  final repository = ref.watch(auditLogRepositoryProvider);
  return LogAuditEventUseCase(repository);
});

final auditLogsListProvider = FutureProvider<List<AuditLog>>((ref) async {
  final repository = ref.watch(auditLogRepositoryProvider);
  final result = await repository.getAll();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (logs) => logs,
  );
});
