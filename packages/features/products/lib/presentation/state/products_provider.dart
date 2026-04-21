import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:products/products.dart';
import 'package:products/application/use_cases/create_product.dart';
import 'package:products/data/repositories_impl/product_repository_impl.dart';

// Repository Provider
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl();
});

// Use Case Providers
final createProductUseCaseProvider = Provider<CreateProductUseCase>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return CreateProductUseCase(repository);
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
