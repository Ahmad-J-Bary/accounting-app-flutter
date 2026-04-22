import 'package:dartz/dartz.dart';
import 'package:foundation/foundation.dart';
import 'package:products/products.dart';

class UpdateProductParams {
  final String id;
  final String name;
  final String? code;
  final String? description;
  final double? salePrice;
  final double? cost;
  final bool isActive;

  UpdateProductParams({
    required this.id,
    required this.name,
    this.code,
    this.description,
    this.salePrice,
    this.cost,
    this.isActive = true,
  });
}

class UpdateProductUseCase extends UseCase<Product, UpdateProductParams> {
  final ProductRepository repository;

  UpdateProductUseCase(this.repository);

  @override
  Future<Either<Failure, Product>> call(UpdateProductParams params) async {
    final productsResult = await repository.getAll();
    return productsResult.fold(
      (failure) => Left(failure),
      (products) {
        final product = products.firstWhere(
          (p) => p.id.value == params.id,
          orElse: () => throw Exception('Product not found'),
        );

        final updatedProduct = Product(
          id: product.id,
          code: params.code ?? product.code,
          name: params.name,
          description: params.description ?? product.description,
          type: product.type,
          categoryId: product.categoryId,
          categoryName: product.categoryName,
          purchasePrice: product.purchasePrice,
          salePrice: params.salePrice ?? product.salePrice,
          cost: params.cost ?? product.cost,
          unit: product.unit,
          taxRate: product.taxRate,
          isActive: params.isActive,
          createdAt: product.createdAt,
          updatedAt: DateTime.now(),
        );

        return repository.update(updatedProduct);
      },
    );
  }
}
