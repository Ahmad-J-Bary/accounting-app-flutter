import 'package:dartz/dartz.dart';
import 'package:foundation/foundation.dart';
import 'package:products/products.dart';

class CreateProductParams {
  final String code;
  final String name;
  final String? description;
  final ProductType type;
  final UniqueId? categoryId;
  final String? categoryName;
  final double purchasePrice;
  final double salePrice;
  final double cost;
  final String? unit;
  final double taxRate;

  const CreateProductParams({
    required this.code,
    required this.name,
    this.description,
    required this.type,
    this.categoryId,
    this.categoryName,
    this.purchasePrice = 0,
    this.salePrice = 0,
    this.cost = 0,
    this.unit,
    this.taxRate = 0,
  });
}

class CreateProductUseCase extends UseCase<Product, CreateProductParams> {
  final ProductRepository repository;

  CreateProductUseCase(this.repository);

  @override
  Future<Either<Failure, Product>> call(CreateProductParams params) async {
    final product = Product(
      id: UniqueId(),
      code: params.code,
      name: params.name,
      description: params.description,
      type: params.type,
      categoryId: params.categoryId,
      categoryName: params.categoryName,
      purchasePrice: params.purchasePrice,
      salePrice: params.salePrice,
      cost: params.cost,
      unit: params.unit,
      taxRate: params.taxRate,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    return repository.create(product);
  }
}
