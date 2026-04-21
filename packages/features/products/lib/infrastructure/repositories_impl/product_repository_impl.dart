import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import 'package:products/products.dart';

class ProductRepositoryImpl implements ProductRepository {
  final List<Product> _cache = [];

  @override
  Future<Either<Failure, Product>> getById(UniqueId id) async {
    try {
      final product = _cache.firstWhere(
        (p) => p.id == id,
        orElse: () => throw Exception('Product not found'),
      );
      return Right(product);
    } catch (e) {
      return Left(NotFoundFailure('Product not found'));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> getAll() async {
    try {
      return Right(_cache);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Product>> create(Product entity) async {
    try {
      _cache.add(entity);
      return Right(entity);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Product>> update(Product entity) async {
    try {
      final index = _cache.indexWhere((p) => p.id == entity.id);
      if (index == -1) {
        return Left(NotFoundFailure('Product not found'));
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
      _cache.removeWhere((p) => p.id == id);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> getByType(ProductType type) async {
    try {
      final filtered = _cache.where((p) => p.type == type).toList();
      return Right(filtered);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> getByCategory(UniqueId categoryId) async {
    try {
      final filtered = _cache.where((p) => p.categoryId == categoryId).toList();
      return Right(filtered);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> search(String query) async {
    try {
      final filtered = _cache
          .where((p) =>
              p.name.toLowerCase().contains(query.toLowerCase()) ||
              p.code.toLowerCase().contains(query.toLowerCase()))
          .toList();
      return Right(filtered);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Product>> getByCode(String code) async {
    try {
      final product = _cache.firstWhere(
        (p) => p.code == code,
        orElse: () => throw Exception('Product not found'),
      );
      return Right(product);
    } catch (e) {
      return Left(NotFoundFailure('Product with code $code not found'));
    }
  }
}
