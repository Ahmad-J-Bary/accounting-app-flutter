import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import 'package:accounting/accounting.dart';
import 'package:accounting/data/models/account_model.dart';

abstract class AccountLocalDataSource {
  Future<Either<Failure, List<AccountModel>>> getAll();
  Future<Either<Failure, AccountModel>> getById(String id);
  Future<Either<Failure, List<AccountModel>>> getByType(String type);
  Future<Either<Failure, AccountModel>> create(AccountModel model);
  Future<Either<Failure, AccountModel>> update(AccountModel model);
  Future<Either<Failure, Unit>> delete(String id);
}
