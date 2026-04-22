import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:partners/partners.dart';

// TODO: Initialize database with sqflite directly
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase.instance;
});

final customerRepositoryProvider = Provider<CustomerRepositoryImpl>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return CustomerRepositoryImpl(database);
});

final supplierRepositoryProvider = Provider<SupplierRepositoryImpl>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return SupplierRepositoryImpl(database);
});

final createCustomerUseCaseProvider = Provider<CreateCustomerUseCase>((ref) {
  final repository = ref.watch(customerRepositoryProvider);
  return CreateCustomerUseCase(repository);
});

final updateCustomerUseCaseProvider = Provider<UpdateCustomerUseCase>((ref) {
  final repository = ref.watch(customerRepositoryProvider);
  return UpdateCustomerUseCase(repository);
});

final deleteCustomerUseCaseProvider = Provider<DeleteCustomerUseCase>((ref) {
  final repository = ref.watch(customerRepositoryProvider);
  return DeleteCustomerUseCase(repository);
});

final createSupplierUseCaseProvider = Provider<CreateSupplierUseCase>((ref) {
  final repository = ref.watch(supplierRepositoryProvider);
  return CreateSupplierUseCase(repository);
});

final updateSupplierUseCaseProvider = Provider<UpdateSupplierUseCase>((ref) {
  final repository = ref.watch(supplierRepositoryProvider);
  return UpdateSupplierUseCase(repository);
});

final deleteSupplierUseCaseProvider = Provider<DeleteSupplierUseCase>((ref) {
  final repository = ref.watch(supplierRepositoryProvider);
  return DeleteSupplierUseCase(repository);
});

final customersListProvider = FutureProvider<List<Customer>>((ref) async {
  final repository = ref.watch(customerRepositoryProvider);
  final result = await repository.getAll();
  return result.fold(
    (failure) => throw Exception(failure.toString()),
    (customers) => customers,
  );
});

final suppliersListProvider = FutureProvider<List<Supplier>>((ref) async {
  final repository = ref.watch(supplierRepositoryProvider);
  final result = await repository.getAll();
  return result.fold(
    (failure) => throw Exception(failure.toString()),
    (suppliers) => suppliers,
  );
});
