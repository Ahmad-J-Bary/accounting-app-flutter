import 'package:dartz/dartz.dart';
import 'package:foundation/foundation.dart';
import 'package:inventory/inventory.dart';

abstract class WarehouseRepository extends Repository<Warehouse, UniqueId> {
  Future<Either<Failure, List<Warehouse>>> getActive();
}
