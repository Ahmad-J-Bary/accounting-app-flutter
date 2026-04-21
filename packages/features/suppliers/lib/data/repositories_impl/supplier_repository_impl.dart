import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import 'package:suppliers/suppliers.dart';

class SupplierRepositoryImpl implements SupplierRepository {
  final List<Supplier> _cache = [];

  @override
  Future<Either<Failure, Supplier>> getById(UniqueId id) async {
    try {
      final supplier = _cache.firstWhere(
        (s) => s.id == id,
        orElse: () => throw Exception('Supplier not found'),
      );
      return Right(supplier);
    } catch (e) {
      return Left(NotFoundFailure('Supplier not found'));
    }
  }

  @override
  Future<Either<Failure, List<Supplier>>> getAll() async {
    try {
      return Right(_cache);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Supplier>> create(Supplier entity) async {
    try {
      _cache.add(entity);
      return Right(entity);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Supplier>> update(Supplier entity) async {
    try {
      final index = _cache.indexWhere((s) => s.id == entity.id);
      if (index == -1) {
        return Left(NotFoundFailure('Supplier not found'));
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
      _cache.removeWhere((s) => s.id == id);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Supplier>> getByCode(String code) async {
    try {
      final supplier = _cache.firstWhere(
        (s) => s.code == code,
        orElse: () => throw Exception('Supplier not found'),
      );
      return Right(supplier);
    } catch (e) {
      return Left(NotFoundFailure('Supplier with code $code not found'));
    }
  }

  @override
  Future<Either<Failure, List<Supplier>>> search(String query) async {
    try {
      final filtered = _cache
          .where((s) =>
              s.name.toLowerCase().contains(query.toLowerCase()) ||
              s.code.toLowerCase().contains(query.toLowerCase()))
          .toList();
      return Right(filtered);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
