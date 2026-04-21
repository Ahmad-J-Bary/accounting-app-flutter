import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import 'package:suppliers/suppliers.dart';

abstract class SupplierRepository extends Repository<Supplier, UniqueId> {
  Future<Either<Failure, List<Supplier>> search(String query);
  Future<Either<Failure, Supplier>> getByCode(String code);
}
