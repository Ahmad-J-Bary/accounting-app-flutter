import 'package:sales/sales.dart';
import 'dart:convert';

class SalesInvoiceModel {
  final String id;
  final String invoiceNumber;
  final String customerId;
  final String invoiceDate;
  final String? dueDate;
  final double subtotal;
  final double taxAmount;
  final double discountAmount;
  final double totalAmount;
  final double paidAmount;
  final String status;
  final String? notes;
  final String createdAt;
  final String updatedAt;

  SalesInvoiceModel({
    required this.id,
    required this.invoiceNumber,
    required this.customerId,
    required this.invoiceDate,
    this.dueDate,
    required this.subtotal,
    required this.taxAmount,
    required this.discountAmount,
    required this.totalAmount,
    required this.paidAmount,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SalesInvoiceModel.fromJson(Map<String, dynamic> json) {
    return SalesInvoiceModel(
      id: json['id'] as String,
      invoiceNumber: json['invoiceNumber'] as String,
      customerId: json['customerId'] as String,
      invoiceDate: json['invoiceDate'] as String,
      dueDate: json['dueDate'] as String?,
      subtotal: (json['subtotal'] as num).toDouble(),
      taxAmount: (json['taxAmount'] as num).toDouble(),
      discountAmount: (json['discountAmount'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      paidAmount: (json['paidAmount'] as num).toDouble(),
      status: json['status'] as String,
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoiceNumber': invoiceNumber,
      'customerId': customerId,
      'invoiceDate': invoiceDate,
      if (dueDate != null) 'dueDate': dueDate,
      'subtotal': subtotal,
      'taxAmount': taxAmount,
      'discountAmount': discountAmount,
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'status': status,
      if (notes != null) 'notes': notes,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  static SalesInvoiceModel fromEntity(SalesInvoice entity) {
    return SalesInvoiceModel(
      id: entity.id.value,
      invoiceNumber: entity.invoiceNumber,
      customerId: entity.customerId.value,
      invoiceDate: entity.invoiceDate.toIso8601String(),
      dueDate: entity.dueDate?.toIso8601String(),
      subtotal: entity.subtotal,
      taxAmount: entity.taxAmount,
      discountAmount: entity.discountAmount,
      totalAmount: entity.totalAmount,
      paidAmount: entity.paidAmount,
      status: entity.status.name,
      notes: entity.notes,
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt.toIso8601String(),
    );
  }

  SalesInvoice toEntity() {
    return SalesInvoice(
      id: UniqueId.fromUniqueString(id),
      invoiceNumber: invoiceNumber,
      customerId: UniqueId.fromUniqueString(customerId),
      invoiceDate: DateTime.parse(invoiceDate),
      dueDate: dueDate != null ? DateTime.parse(dueDate!) : null,
      subtotal: subtotal,
      taxAmount: taxAmount,
      discountAmount: discountAmount,
      totalAmount: totalAmount,
      paidAmount: paidAmount,
      status: InvoiceStatus.values.firstWhere((e) => e.name == status),
      notes: notes,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }
}
