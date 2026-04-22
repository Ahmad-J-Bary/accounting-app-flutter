import 'package:dartz/dartz.dart';
import 'package:foundation/foundation.dart';
import 'package:inventory/inventory.dart';

class WarehouseRepositoryImpl implements WarehouseRepository {
  final List<Warehouse> _cache = [];

  @override
  Future<Either<Failure, List<Warehouse>>> getActive() async {
    try {
      final active = _cache.where((w) => w.isActive).toList();
      return Right(active);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Warehouse>> getById(UniqueId id) async {
    try {
      final warehouse = _cache.firstWhere(
        (w) => w.id == id,
        orElse: () => throw Exception('Warehouse not found'),
      );
      return Right(warehouse);
    } catch (e) {
      return Left(NotFoundFailure('Warehouse not found'));
    }
  }

  @override
  Future<Either<Failure, List<Warehouse>>> getAll() async {
    try {
      return Right(_cache);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Warehouse>> create(Warehouse entity) async {
    try {
      _cache.add(entity);
      return Right(entity);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Warehouse>> update(Warehouse entity) async {
    try {
      final index = _cache.indexWhere((w) => w.id == entity.id);
      if (index == -1) {
        return Left(NotFoundFailure('Warehouse not found'));
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
      _cache.removeWhere((w) => w.id == id);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
