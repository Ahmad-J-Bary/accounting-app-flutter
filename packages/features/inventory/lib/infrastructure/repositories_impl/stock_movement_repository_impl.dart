import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import 'package:inventory/inventory.dart';

class StockMovementRepositoryImpl implements StockMovementRepository {
  final List<StockMovement> _cache = [];

  @override
  Future<Either<Failure, StockMovement>> getById(UniqueId id) async {
    try {
      final movement = _cache.firstWhere(
        (m) => m.id == id,
        orElse: () => throw Exception('Stock movement not found'),
      );
      return Right(movement);
    } catch (e) {
      return Left(NotFoundFailure('Stock movement not found'));
    }
  }

  @override
  Future<Either<Failure, List<StockMovement>>> getAll() async {
    try {
      return Right(_cache);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, StockMovement>> create(StockMovement entity) async {
    try {
      _cache.add(entity);
      return Right(entity);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, StockMovement>> update(StockMovement entity) async {
    try {
      final index = _cache.indexWhere((m) => m.id == entity.id);
      if (index == -1) {
        return Left(NotFoundFailure('Stock movement not found'));
      }
      _cache[index] = entity;
      return Right(entity);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> delete(UniqueId id) async {
    try {
      _cache.removeWhere((m) => m.id == id);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<StockMovement>>> getByProduct(UniqueId productId) async {
    try {
      final filtered = _cache.where((m) => m.productId == productId).toList();
      return Right(filtered);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<StockMovement>>> getByWarehouse(UniqueId warehouseId) async {
    try {
      final filtered = _cache.where((m) => m.warehouseId == warehouseId).toList();
      return Right(filtered);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<StockMovement>>> getByDateRange(DateTime start, DateTime end) async {
    try {
      final filtered = _cache
          .where((m) => m.movementDate.isAfter(start) && m.movementDate.isBefore(end))
          .toList();
      return Right(filtered);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<StockMovement>>> getByType(StockMovementType type) async {
    try {
      final filtered = _cache.where((m) => m.type == type).toList();
      return Right(filtered);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
