import 'package:sales/sales.dart';
import 'dart:convert';

class SalesInvoiceItemModel {
  final String id;
  final String invoiceId;
  final String productId;
  final String productName;
  final double quantity;
  final double unitPrice;
  final double discountAmount;
  final double taxAmount;
  final double lineTotal;

  SalesInvoiceItemModel({
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

  factory SalesInvoiceItemModel.fromJson(Map<String, dynamic> json) {
    return SalesInvoiceItemModel(
      id: json['id'] as String,
      invoiceId: json['invoiceId'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unitPrice: (json['unitPrice'] as num).toDouble(),
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0,
      taxAmount: (json['taxAmount'] as num?)?.toDouble() ?? 0,
      lineTotal: (json['lineTotal'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoiceId': invoiceId,
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'discountAmount': discountAmount,
      'taxAmount': taxAmount,
      'lineTotal': lineTotal,
    };
  }

  static SalesInvoiceItemModel fromEntity(SalesInvoiceItem entity) {
    return SalesInvoiceItemModel(
      id: entity.id.value,
      invoiceId: entity.invoiceId.value,
      productId: entity.productId.value,
      productName: entity.productName,
      quantity: entity.quantity,
      unitPrice: entity.unitPrice,
      discountAmount: entity.discountAmount,
      taxAmount: entity.taxAmount,
      lineTotal: entity.lineTotal,
    );
  }

  SalesInvoiceItem toEntity() {
    return SalesInvoiceItem(
      id: UniqueId.fromUniqueString(id),
      invoiceId: UniqueId.fromUniqueString(invoiceId),
      productId: UniqueId.fromUniqueString(productId),
      productName: productName,
      quantity: quantity,
      unitPrice: unitPrice,
      discountAmount: discountAmount,
      taxAmount: taxAmount,
      lineTotal: lineTotal,
    );
  }
}
