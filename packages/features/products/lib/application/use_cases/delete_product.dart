import 'package:dartz/dartz.dart';
import 'package:foundation/foundation.dart';
import 'package:products/products.dart';

class DeleteProductUseCase extends UseCase<void, String> {
  final ProductRepository repository;

  DeleteProductUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String id) async {
    final productsResult = await repository.getAll();
    return productsResult.fold(
      (failure) => Left(failure),
      (products) {
        final product = products.firstWhere(
          (p) => p.id.value == id,
          orElse: () => throw Exception('Product not found'),
        );
        return repository.delete(product.id);
      },
    );
  }
}
