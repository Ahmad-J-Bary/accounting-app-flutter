import 'package:dartz/dartz.dart';
import 'package:foundation/foundation.dart';
import 'package:sales/sales.dart';
import 'package:inventory/inventory.dart';
import 'package:accounting/accounting.dart';

class CompleteSaleParams {
  final String invoiceNumber;
  final UniqueId customerId;
  final DateTime invoiceDate;
  final List<SaleItem> items;
  final String? notes;

  CompleteSaleParams({
    required this.invoiceNumber,
    required this.customerId,
    required this.invoiceDate,
    required this.items,
    this.notes,
  });
}

class SaleItem {
  final UniqueId productId;
  final String productName;
  final double quantity;
  final double unitPrice;
  final double taxRate;

  SaleItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    this.taxRate = 0,
  });

  double get lineTotal => quantity * unitPrice;
  double get lineTax => lineTotal * taxRate;
  double get lineTotalWithTax => lineTotal + lineTax;
}

class CompleteSaleWorkflow extends UseCase<String, CompleteSaleParams> {
  // These will be injected via DI in production
  // For now, we'll have placeholder methods
  
  @override
  Future<Either<Failure, String>> call(CompleteSaleParams params) async {
    // 1. Create sales invoice
    // 2. Deduct inventory
    // 3. Post journal entry
    // 4. Update customer balance
    // 5. Emit SaleCompleted event
    
    // This is a placeholder implementation
    // In production, this would call actual use cases from the features
    return Right(params.invoiceNumber);
  }
}
