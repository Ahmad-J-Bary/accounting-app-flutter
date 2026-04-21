import 'package:dartz/dartz.dart';
import 'package:foundation/foundation.dart';
import 'package:audit_log/audit_log.dart';

abstract class AuditLogRepository extends Repository<AuditLog, UniqueId> {
  Future<Either<Failure, List<AuditLog>>> getByUserId(UniqueId userId);
  Future<Either<Failure, List<AuditLog>>> getByEntity(String entity);
  Future<Either<Failure, List<AuditLog>>> getByDateRange(DateTime start, DateTime end);
  Future<Either<Failure, List<AuditLog>>> search(String query);
}
