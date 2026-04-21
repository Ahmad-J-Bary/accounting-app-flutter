import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import 'package:accounting/accounting.dart';
import 'package:accounting/data/datasources/account_local_datasource.dart';
import 'package:accounting/data/datasources/account_remote_datasource.dart';
import 'package:accounting/data/models/account_model.dart';

class AccountRepositoryImpl implements AccountRepository {
  final AccountLocalDataSource localDataSource;
  final AccountRemoteDataSource remoteDataSource;

  AccountRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, Account>> getById(UniqueId id) async {
    try {
      final result = await localDataSource.getById(id.value);
      return result.fold(
        (failure) => Left(failure),
        (model) => Right(model.toEntity()),
      );
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Account>>> getAll() async {
    try {
      final result = await localDataSource.getAll();
      return result.fold(
        (failure) => Left(failure),
        (models) => Right(models.map((m) => m.toEntity()).toList()),
      );
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Account>> create(Account entity) async {
    try {
      final model = AccountModel.fromEntity(entity);
      final result = await localDataSource.create(model);
      return result.fold(
        (failure) => Left(failure),
        (model) => Right(model.toEntity()),
      );
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Account>> update(Account entity) async {
    try {
      final model = AccountModel.fromEntity(entity);
      final result = await localDataSource.update(model);
      return result.fold(
        (failure) => Left(failure),
        (model) => Right(model.toEntity()),
      );
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> delete(UniqueId id) async {
    try {
      final result = await localDataSource.delete(id.value);
      return result.fold(
        (failure) => Left(failure),
        (_) => const Right(unit),
      );
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Account>>> getByType(AccountType type) async {
    try {
      final result = await localDataSource.getByType(type.name);
      return result.fold(
        (failure) => Left(failure),
        (models) => Right(models.map((m) => m.toEntity()).toList()),
      );
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Account>>> search(String query) async {
    try {
      final result = await localDataSource.getAll();
      return result.fold(
        (failure) => Left(failure),
        (models) {
          final filtered = models
              .where((m) =>
                  m.name.toLowerCase().contains(query.toLowerCase()) ||
                  m.code.toLowerCase().contains(query.toLowerCase()))
              .map((m) => m.toEntity())
              .toList();
          return Right(filtered);
        },
      );
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Account>> getByCode(String code) async {
    try {
      final result = await localDataSource.getAll();
      return result.fold(
        (failure) => Left(failure),
        (models) {
          final model = models.firstWhere(
            (m) => m.code == code,
            orElse: () => throw Exception('Account not found'),
          );
          return Right(model.toEntity());
        },
      );
    } catch (e) {
      return Left(NotFoundFailure('Account with code $code not found'));
    }
  }
}
