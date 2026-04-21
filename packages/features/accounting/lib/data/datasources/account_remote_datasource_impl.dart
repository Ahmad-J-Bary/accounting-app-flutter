import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import 'package:accounting/accounting.dart';
import 'package:accounting/data/models/account_model.dart';
import 'package:accounting/data/datasources/account_remote_datasource.dart';

class AccountRemoteDataSourceImpl implements AccountRemoteDataSource {
  @override
  Future<Either<Failure, List<AccountModel>>> getAll() async {
    try {
      // In a real implementation, this would make an API call
      return const Left(NetworkFailure('Not implemented'));
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AccountModel>> getById(String id) async {
    try {
      return const Left(NetworkFailure('Not implemented'));
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AccountModel>>> getByType(String type) async {
    try {
      return const Left(NetworkFailure('Not implemented'));
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AccountModel>> create(AccountModel model) async {
    try {
      return const Left(NetworkFailure('Not implemented'));
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AccountModel>> update(AccountModel model) async {
    try {
      return const Left(NetworkFailure('Not implemented'));
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> delete(String id) async {
    try {
      return const Left(NetworkFailure('Not implemented'));
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }
}
