import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import 'package:sales/sales.dart';

class CreateSalesInvoiceParams {
  final String invoiceNumber;
  final UniqueId customerId;
  final DateTime invoiceDate;
  final DateTime? dueDate;
  final List<SalesInvoiceItem> items;
  final String? notes;

  const CreateSalesInvoiceParams({
    required this.invoiceNumber,
    required this.customerId,
    required this.invoiceDate,
    this.dueDate,
    required this.items,
    this.notes,
  });
}

class CreateSalesInvoiceUseCase extends UseCase<SalesInvoice, CreateSalesInvoiceParams> {
  final SalesInvoiceRepository repository;

  CreateSalesInvoiceUseCase(this.repository);

  @override
  Future<Either<Failure, SalesInvoice>> call(CreateSalesInvoiceParams params) async {
    final subtotal = params.items.fold<double>(
      0,
      (sum, item) => sum + (item.quantity * item.unitPrice),
    );
    final taxAmount = params.items.fold<double>(
      0,
      (sum, item) => sum + item.taxAmount,
    );
    final discountAmount = params.items.fold<double>(
      0,
      (sum, item) => sum + item.discountAmount,
    );
    final totalAmount = subtotal + taxAmount - discountAmount;

    final invoice = SalesInvoice(
      id: UniqueId(),
      invoiceNumber: params.invoiceNumber,
      customerId: params.customerId,
      invoiceDate: params.invoiceDate,
      dueDate: params.dueDate,
      subtotal: subtotal,
      taxAmount: taxAmount,
      discountAmount: discountAmount,
      totalAmount: totalAmount,
      paidAmount: 0,
      status: InvoiceStatus.draft,
      notes: params.notes,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    return repository.create(invoice);
  }
}
