import 'package:dartz/dartz.dart';
import 'package:foundation/foundation.dart';
import 'package:audit_log/audit_log.dart';

class LogAuditEventParams {
  final UniqueId userId;
  final String username;
  final AuditAction action;
  final String entity;
  final String? entityId;
  final Map<String, dynamic>? changes;
  final String? description;
  final String? ipAddress;
  final String? userAgent;

  LogAuditEventParams({
    required this.userId,
    required this.username,
    required this.action,
    required this.entity,
    this.entityId,
    this.changes,
    this.description,
    this.ipAddress,
    this.userAgent,
  });
}

class LogAuditEventUseCase extends UseCase<AuditLog, LogAuditEventParams> {
  final AuditLogRepository repository;

  LogAuditEventUseCase(this.repository);

  @override
  Future<Either<Failure, AuditLog>> call(LogAuditEventParams params) async {
    final auditLog = AuditLog(
      id: UniqueId(),
      userId: params.userId,
      username: params.username,
      action: params.action,
      entity: params.entity,
      entityId: params.entityId,
      changes: params.changes,
      description: params.description,
      timestamp: DateTime.now(),
      ipAddress: params.ipAddress,
      userAgent: params.userAgent,
    );

    return await repository.create(auditLog);
  }
}
