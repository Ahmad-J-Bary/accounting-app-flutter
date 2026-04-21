import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import 'package:accounting/accounting.dart';

class GetAccountsUseCase extends UseCase<List<Account>, NoParams> {
  final AccountRepository repository;

  GetAccountsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Account>>> call(NoParams params) {
    return repository.getAll();
  }
}

class GetAccountsByTypeParams {
  final AccountType type;

  const GetAccountsByTypeParams({required this.type});
}

class GetAccountsByTypeUseCase extends UseCase<List<Account>, GetAccountsByTypeParams> {
  final AccountRepository repository;

  GetAccountsByTypeUseCase(this.repository);

  @override
  Future<Either<Failure, List<Account>>> call(GetAccountsByTypeParams params) {
    return repository.getByType(params.type);
  }
}
