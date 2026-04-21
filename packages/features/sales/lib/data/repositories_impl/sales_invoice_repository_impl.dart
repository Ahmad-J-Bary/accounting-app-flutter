import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import 'package:sales/sales.dart';

class SalesInvoiceRepositoryImpl implements SalesInvoiceRepository {
  final List<SalesInvoice> _cache = [];

  @override
  Future<Either<Failure, SalesInvoice>> getById(UniqueId id) async {
    try {
      final invoice = _cache.firstWhere(
        (i) => i.id == id,
        orElse: () => throw Exception('Invoice not found'),
      );
      return Right(invoice);
    } catch (e) {
      return Left(NotFoundFailure('Invoice not found'));
    }
  }

  @override
  Future<Either<Failure, List<SalesInvoice>>> getAll() async {
    try {
      return Right(_cache);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SalesInvoice>> create(SalesInvoice entity) async {
    try {
      _cache.add(entity);
      return Right(entity);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SalesInvoice>> update(SalesInvoice entity) async {
    try {
      final index = _cache.indexWhere((i) => i.id == entity.id);
      if (index == -1) {
        return Left(NotFoundFailure('Invoice not found'));
      }
      _cache[index] = entity;
      return Right(entity);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> delete(UniqueId id) async {
    try {
      _cache.removeWhere((i) => i.id == id);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SalesInvoice>>> getByCustomer(UniqueId customerId) async {
    try {
      final filtered = _cache.where((i) => i.customerId == customerId).toList();
      return Right(filtered);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SalesInvoice>>> getByDateRange(DateTime start, DateTime end) async {
    try {
      final filtered = _cache
          .where((i) => i.invoiceDate.isAfter(start) && i.invoiceDate.isBefore(end))
          .toList();
      return Right(filtered);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SalesInvoice>>> getByStatus(InvoiceStatus status) async {
    try {
      final filtered = _cache.where((i) => i.status == status).toList();
      return Right(filtered);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SalesInvoice>> getByNumber(String invoiceNumber) async {
    try {
      final invoice = _cache.firstWhere(
        (i) => i.invoiceNumber == invoiceNumber,
        orElse: () => throw Exception('Invoice not found'),
      );
      return Right(invoice);
    } catch (e) {
      return Left(NotFoundFailure('Invoice with number $invoiceNumber not found'));
    }
  }
}
