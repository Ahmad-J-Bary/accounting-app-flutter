import 'package:equatable/equatable.dart';
import 'package:shared/shared.dart';

enum InvoiceStatus {
  draft,
  posted,
  paid,
  partiallyPaid,
  cancelled,
}

class SalesInvoice extends Equatable {
  final UniqueId id;
  final String invoiceNumber;
  final UniqueId customerId;
  final DateTime invoiceDate;
  final DateTime? dueDate;
  final double subtotal;
  final double taxAmount;
  final double discountAmount;
  final double totalAmount;
  final double paidAmount;
  final InvoiceStatus status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SalesInvoice({
    required this.id,
    required this.invoiceNumber,
    required this.customerId,
    required this.invoiceDate,
    this.dueDate,
    this.subtotal = 0,
    this.taxAmount = 0,
    this.discountAmount = 0,
    this.totalAmount = 0,
    this.paidAmount = 0,
    this.status = InvoiceStatus.draft,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  double get remainingAmount => totalAmount - paidAmount;

  @override
  List<Object?> get props => [
        id,
        invoiceNumber,
        customerId,
        invoiceDate,
        dueDate,
        subtotal,
        taxAmount,
        discountAmount,
        totalAmount,
        paidAmount,
        status,
        notes,
        createdAt,
        updatedAt,
      ];
}
