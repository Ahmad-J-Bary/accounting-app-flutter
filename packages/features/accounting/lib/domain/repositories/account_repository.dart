import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import 'package:accounting/accounting.dart';

abstract class AccountRepository extends Repository<Account, UniqueId> {
  Future<Either<Failure, List<Account>> getByType(AccountType type);
  Future<Either<Failure, List<Account>> search(String query);
  Future<Either<Failure, Account>> getByCode(String code);
}
