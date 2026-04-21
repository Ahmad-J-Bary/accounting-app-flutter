import 'package:dartz/dartz.dart';
import 'package:foundation/foundation.dart';

abstract class Repository<T, ID> {
  Future<Either<Failure, T>> getById(ID id);
  Future<Either<Failure, List<T>>> getAll();
  Future<Either<Failure, T>> create(T entity);
  Future<Either<Failure, T>> update(T entity);
  Future<Either<Failure, Unit>> delete(ID id);
}
