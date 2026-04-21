import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:platform/local_db/local_db.dart';
import 'package:partners/partners.dart';

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

final createSupplierUseCaseProvider = Provider<CreateSupplierUseCase>((ref) {
  final repository = ref.watch(supplierRepositoryProvider);
  return CreateSupplierUseCase(repository);
});

final customersListProvider = FutureProvider<List<Customer>>((ref) async {
  final repository = ref.watch(customerRepositoryProvider);
  final result = await repository.getAll();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (customers) => customers,
  );
});

final suppliersListProvider = FutureProvider<List<Supplier>>((ref) async {
  final repository = ref.watch(supplierRepositoryProvider);
  final result = await repository.getAll();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (suppliers) => suppliers,
  );
});
