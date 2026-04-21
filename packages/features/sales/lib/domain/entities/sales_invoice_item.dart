import 'package:equatable/equatable.dart';
import 'package:foundation/foundation.dart';

class SalesInvoiceItem extends Equatable {
  final UniqueId id;
  final UniqueId invoiceId;
  final UniqueId productId;
  final String productName;
  final double quantity;
  final double unitPrice;
  final double discountAmount;
  final double taxAmount;
  final double lineTotal;

  const SalesInvoiceItem({
    required this.id,
    required this.invoiceId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    this.discountAmount = 0,
    this.taxAmount = 0,
    required this.lineTotal,
  });

  @override
  List<Object?> get props => [
        id,
        invoiceId,
        productId,
        productName,
        quantity,
        unitPrice,
        discountAmount,
        taxAmount,
        lineTotal,
      ];
}
