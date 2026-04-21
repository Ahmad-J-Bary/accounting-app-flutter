import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:customers/customers.dart';
import 'package:customers/application/use_cases/create_customer.dart';
import 'package:customers/application/use_cases/get_customers.dart';
import 'package:customers/application/use_cases/search_customers.dart';
import 'package:customers/data/repositories_impl/customer_repository_impl.dart';

// Repository Provider
final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return CustomerRepositoryImpl();
});

// Use Case Providers
final createCustomerUseCaseProvider = Provider<CreateCustomerUseCase>((ref) {
  final repository = ref.watch(customerRepositoryProvider);
  return CreateCustomerUseCase(repository);
});

final getCustomersUseCaseProvider = Provider<GetCustomersUseCase>((ref) {
  final repository = ref.watch(customerRepositoryProvider);
  return GetCustomersUseCase(repository);
});

final searchCustomersUseCaseProvider = Provider<SearchCustomersUseCase>((ref) {
  final repository = ref.watch(customerRepositoryProvider);
  return SearchCustomersUseCase(repository);
});

// State Providers
final customersListProvider = FutureProvider.autoDispose<List<Customer>>((ref) async {
  final useCase = ref.watch(getCustomersUseCaseProvider);
  final result = await useCase(const NoParams());
  return result.fold(
    (failure) => throw Exception(failure.toString()),
    (customers) => customers,
  );
});

final customersSearchQueryProvider = StateProvider<String>((ref) => '');

final customersSearchResultsProvider = FutureProvider.autoDispose<List<Customer>>((ref) async {
  final query = ref.watch(customersSearchQueryProvider);
  if (query.isEmpty) {
    return [];
  }
  final useCase = ref.watch(searchCustomersUseCaseProvider);
  final result = await useCase(SearchCustomersParams(query: query));
  return result.fold(
    (failure) => throw Exception(failure.toString()),
    (customers) => customers,
  );
});
