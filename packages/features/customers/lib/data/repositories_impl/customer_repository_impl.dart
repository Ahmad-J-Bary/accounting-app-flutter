import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import 'package:customers/customers.dart';
import 'package:customers/data/models/customer_model.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  // In a real implementation, this would use local/remote data sources
  final List<CustomerModel> _cache = [];

  @override
  Future<Either<Failure, Customer>> getById(UniqueId id) async {
    try {
      final model = _cache.firstWhere(
        (m) => m.id == id.value,
        orElse: () => throw Exception('Customer not found'),
      );
      return Right(model.toEntity());
    } catch (e) {
      return Left(NotFoundFailure('Customer not found'));
    }
  }

  @override
  Future<Either<Failure, List<Customer>>> getAll() async {
    try {
      return Right(_cache.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Customer>> create(Customer entity) async {
    try {
      final model = CustomerModel.fromEntity(entity);
      _cache.add(model);
      return Right(model.toEntity());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Customer>> update(Customer entity) async {
    try {
      final index = _cache.indexWhere((m) => m.id == entity.id.value);
      if (index == -1) {
        return Left(NotFoundFailure('Customer not found'));
      }
      _cache[index] = CustomerModel.fromEntity(entity);
      return Right(entity);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> delete(UniqueId id) async {
    try {
      _cache.removeWhere((m) => m.id == id.value);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Customer>>> search(String query) async {
    try {
      final filtered = _cache
          .where((m) =>
              m.name.toLowerCase().contains(query.toLowerCase()) ||
              m.code.toLowerCase().contains(query.toLowerCase()))
          .map((m) => m.toEntity())
          .toList();
      return Right(filtered);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Customer>> getByCode(String code) async {
    try {
      final model = _cache.firstWhere(
        (m) => m.code == code,
        orElse: () => throw Exception('Customer not found'),
      );
      return Right(model.toEntity());
    } catch (e) {
      return Left(NotFoundFailure('Customer with code $code not found'));
    }
  }
}
