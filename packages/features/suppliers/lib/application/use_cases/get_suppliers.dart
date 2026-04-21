import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import 'package:suppliers/suppliers.dart';

class GetSuppliersUseCase extends UseCase<List<Supplier>, NoParams> {
  final SupplierRepository repository;

  GetSuppliersUseCase(this.repository);

  @override
  Future<Either<Failure, List<Supplier>>> call(NoParams params) {
    return repository.getAll();
  }
}

class SearchSuppliersParams {
  final String query;

  SearchSuppliersParams({required this.query});
}

class SearchSuppliersUseCase extends UseCase<List<Supplier>, SearchSuppliersParams> {
  final SupplierRepository repository;

  SearchSuppliersUseCase(this.repository);

  @override
  Future<Either<Failure, List<Supplier>>> call(SearchSuppliersParams params) {
    return repository.search(params.query);
  }
}
