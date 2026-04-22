import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:products/products.dart';
import 'package:products/application/use_cases/create_product.dart';
import 'package:products/application/use_cases/update_product.dart';
import 'package:products/application/use_cases/delete_product.dart';
import 'package:products/infrastructure/repositories_impl/product_repository_impl.dart';

// Repository Provider
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl();
});

// Use Case Providers
final createProductUseCaseProvider = Provider<CreateProductUseCase>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return CreateProductUseCase(repository);
});

final updateProductUseCaseProvider = Provider<UpdateProductUseCase>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return UpdateProductUseCase(repository);
});

final deleteProductUseCaseProvider = Provider<DeleteProductUseCase>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return DeleteProductUseCase(repository);
});

// State Providers
final productsListProvider = FutureProvider.autoDispose<List<Product>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);
  final result = await repository.getAll();
  return result.fold(
    (failure) => throw Exception(failure.toString()),
    (products) => products,
  );
});
