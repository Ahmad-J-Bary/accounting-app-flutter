import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import 'package:sales/sales.dart';

abstract class SalesInvoiceRepository extends Repository<SalesInvoice, UniqueId> {
  Future<Either<Failure, List<SalesInvoice>> getByCustomer(UniqueId customerId);
  Future<Either<Failure, List<SalesInvoice>> getByDateRange(DateTime start, DateTime end);
  Future<Either<Failure, List<SalesInvoice>> getByStatus(InvoiceStatus status);
  Future<Either<Failure, SalesInvoice>> getByNumber(String invoiceNumber);
}
