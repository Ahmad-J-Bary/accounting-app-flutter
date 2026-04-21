import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:suppliers/suppliers.dart';
import 'package:suppliers/application/use_cases/create_supplier.dart';
import 'package:suppliers/application/use_cases/get_suppliers.dart';
import 'package:suppliers/data/repositories_impl/supplier_repository_impl.dart';

// Repository Provider
final supplierRepositoryProvider = Provider<SupplierRepository>((ref) {
  return SupplierRepositoryImpl();
});

// Use Case Providers
final createSupplierUseCaseProvider = Provider<CreateSupplierUseCase>((ref) {
  final repository = ref.watch(supplierRepositoryProvider);
  return CreateSupplierUseCase(repository);
});

final getSuppliersUseCaseProvider = Provider<GetSuppliersUseCase>((ref) {
  final repository = ref.watch(supplierRepositoryProvider);
  return GetSuppliersUseCase(repository);
});

final searchSuppliersUseCaseProvider = Provider<SearchSuppliersUseCase>((ref) {
  final repository = ref.watch(supplierRepositoryProvider);
  return SearchSuppliersUseCase(repository);
});

// State Providers
final suppliersListProvider = FutureProvider.autoDispose<List<Supplier>>((ref) async {
  final useCase = ref.watch(getSuppliersUseCaseProvider);
  final result = await useCase(const NoParams());
  return result.fold(
    (failure) => throw Exception(failure.toString()),
    (suppliers) => suppliers,
  );
});

final suppliersSearchQueryProvider = StateProvider<String>((ref) => '');

final suppliersSearchResultsProvider = FutureProvider.autoDispose<List<Supplier>>((ref) async {
  final query = ref.watch(suppliersSearchQueryProvider);
  if (query.isEmpty) {
    return [];
  }
  final useCase = ref.watch(searchSuppliersUseCaseProvider);
  final result = await useCase(SearchSuppliersParams(query: query));
  return result.fold(
    (failure) => throw Exception(failure.toString()),
    (suppliers) => suppliers,
  );
});
