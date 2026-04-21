import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import 'package:products/products.dart';

abstract class ProductRepository extends Repository<Product, UniqueId> {
  Future<Either<Failure, List<Product>> getByType(ProductType type);
  Future<Either<Failure, List<Product>> getByCategory(UniqueId categoryId);
  Future<Either<Failure, List<Product>> search(String query);
  Future<Either<Failure, Product>> getByCode(String code);
}
