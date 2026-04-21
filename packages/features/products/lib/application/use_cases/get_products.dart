import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import 'package:products/products.dart';

class GetProductsUseCase extends UseCase<List<Product>, NoParams> {
  final ProductRepository repository;

  GetProductsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Product>>> call(NoParams params) {
    return repository.getAll();
  }
}
