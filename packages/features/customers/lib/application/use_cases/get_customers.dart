import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import 'package:customers/customers.dart';

class GetCustomersUseCase extends UseCase<List<Customer>, NoParams> {
  final CustomerRepository repository;

  GetCustomersUseCase(this.repository);

  @override
  Future<Either<Failure, List<Customer>>> call(NoParams params) {
    return repository.getAll();
  }
}

class SearchCustomersParams {
  final String query;

  const SearchCustomersParams({required this.query});
}

class SearchCustomersUseCase extends UseCase<List<Customer>, SearchCustomersParams> {
  final CustomerRepository repository;

  SearchCustomersUseCase(this.repository);

  @override
  Future<Either<Failure, List<Customer>>> call(SearchCustomersParams params) {
    return repository.search(params.query);
  }
}
