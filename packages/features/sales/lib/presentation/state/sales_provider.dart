import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales/sales.dart';
import 'package:sales/application/use_cases/create_sales_invoice.dart';
import 'package:sales/data/repositories_impl/sales_invoice_repository_impl.dart';

// Repository Provider
final salesInvoiceRepositoryProvider = Provider<SalesInvoiceRepository>((ref) {
  return SalesInvoiceRepositoryImpl();
});

// Use Case Providers
final createSalesInvoiceUseCaseProvider = Provider<CreateSalesInvoiceUseCase>((ref) {
  final repository = ref.watch(salesInvoiceRepositoryProvider);
  return CreateSalesInvoiceUseCase(repository);
});

// State Providers
final salesInvoicesListProvider = FutureProvider.autoDispose<List<SalesInvoice>>((ref) async {
  final repository = ref.watch(salesInvoiceRepositoryProvider);
  final result = await repository.getAll();
  return result.fold(
    (failure) => throw Exception(failure.toString()),
    (invoices) => invoices,
  );
});
