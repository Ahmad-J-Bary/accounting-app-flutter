import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import 'package:accounting/accounting.dart';
import 'package:accounting/data/models/account_model.dart';
import 'package:accounting/data/datasources/account_local_datasource.dart';

class AccountLocalDataSourceImpl implements AccountLocalDataSource {
  final List<AccountModel> _cache = [];

  @override
  Future<Either<Failure, List<AccountModel>>> getAll() async {
    try {
      return Right(_cache);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AccountModel>> getById(String id) async {
    try {
      final model = _cache.firstWhere(
        (m) => m.id == id,
        orElse: () => throw Exception('Account not found'),
      );
      return Right(model);
    } catch (e) {
      return Left(NotFoundFailure('Account not found'));
    }
  }

  @override
  Future<Either<Failure, List<AccountModel>>> getByType(String type) async {
    try {
      final filtered = _cache.where((m) => m.type == type).toList();
      return Right(filtered);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AccountModel>> create(AccountModel model) async {
    try {
      _cache.add(model);
      return Right(model);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AccountModel>> update(AccountModel model) async {
    try {
      final index = _cache.indexWhere((m) => m.id == model.id);
      if (index == -1) {
        return Left(NotFoundFailure('Account not found'));
      }
      _cache[index] = model;
      return Right(model);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> delete(String id) async {
    try {
      _cache.removeWhere((m) => m.id == id);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
