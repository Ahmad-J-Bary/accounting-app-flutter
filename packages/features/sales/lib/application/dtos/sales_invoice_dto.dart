class SalesInvoiceDto {
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

  SalesInvoiceDto({
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

  factory SalesInvoiceDto.fromJson(Map<String, dynamic> json) {
    return SalesInvoiceDto(
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
      'dueDate': dueDate,
      'subtotal': subtotal,
      'taxAmount': taxAmount,
      'discountAmount': discountAmount,
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'status': status,
      'notes': notes,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
