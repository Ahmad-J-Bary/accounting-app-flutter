import 'package:dartz/dartz.dart';
import 'package:platform/local_db/local_db.dart';
import 'package:foundation/foundation.dart';
import 'package:audit_log/audit_log.dart';

class AuditLogRepositoryImpl implements AuditLogRepository {
  final AppDatabase database;
  final List<AuditLog> _cache = [];

  AuditLogRepositoryImpl(this.database);

  @override
  Future<Either<Failure, AuditLog>> getById(UniqueId id) async {
    try {
      final cached = _cache.firstWhere((log) => log.id == id);
      return Right(cached);
    } catch (e) {
      return Left(Failure(message: 'Audit log not found: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<AuditLog>>> getAll() async {
    try {
      if (_cache.isNotEmpty) return Right(_cache);

      // Return sample data
      final logs = [
        AuditLog(
          id: UniqueId(),
          userId: UniqueId(),
          username: 'admin',
          action: AuditAction.login,
          entity: 'User',
          timestamp: DateTime.now(),
        ),
      ];
      _cache.addAll(logs);
      return Right(logs);
    } catch (e) {
      return Left(Failure(message: 'Failed to get audit logs: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, AuditLog>> create(AuditLog entity) async {
    try {
      _cache.add(entity);
      // In production, insert into database
      return Right(entity);
    } catch (e) {
      return Left(Failure(message: 'Failed to create audit log: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, AuditLog>> update(AuditLog entity) async {
    try {
      final index = _cache.indexWhere((log) => log.id == entity.id);
      if (index != -1) {
        _cache[index] = entity;
        return Right(entity);
      }
      return Left(Failure(message: 'Audit log not found'));
    } catch (e) {
      return Left(Failure(message: 'Failed to update audit log: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> delete(UniqueId id) async {
    try {
      _cache.removeWhere((log) => log.id == id);
      return const Right(unit);
    } catch (e) {
      return Left(Failure(message: 'Failed to delete audit log: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<AuditLog>>> getByUserId(UniqueId userId) async {
    try {
      final logs = _cache.where((log) => log.userId == userId).toList();
      return Right(logs);
    } catch (e) {
      return Left(Failure(message: 'Failed to get audit logs by user: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<AuditLog>>> getByEntity(String entity) async {
    try {
      final logs = _cache.where((log) => log.entity == entity).toList();
      return Right(logs);
    } catch (e) {
      return Left(Failure(message: 'Failed to get audit logs by entity: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<AuditLog>>> getByDateRange(DateTime start, DateTime end) async {
    try {
      final logs = _cache.where((log) =>
          log.timestamp.isAfter(start) && log.timestamp.isBefore(end)
      ).toList();
      return Right(logs);
    } catch (e) {
      return Left(Failure(message: 'Failed to get audit logs by date range: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<AuditLog>>> search(String query) async {
    try {
      final logs = _cache.where((log) =>
          log.username.toLowerCase().contains(query.toLowerCase()) ||
          log.entity.toLowerCase().contains(query.toLowerCase()) ||
          (log.description?.toLowerCase().contains(query.toLowerCase()) ?? false)
      ).toList();
      return Right(logs);
    } catch (e) {
      return Left(Failure(message: 'Failed to search audit logs: ${e.toString()}'));
    }
  }
}
