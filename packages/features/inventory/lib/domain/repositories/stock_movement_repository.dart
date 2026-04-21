import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import 'package:inventory/inventory.dart';

abstract class StockMovementRepository extends Repository<StockMovement, UniqueId> {
  Future<Either<Failure, List<StockMovement>> getByProduct(UniqueId productId);
  Future<Either<Failure, List<StockMovement>> getByWarehouse(UniqueId warehouseId);
  Future<Either<Failure, List<StockMovement>> getByDateRange(DateTime start, DateTime end);
  Future<Either<Failure, List<StockMovement>> getByType(MovementType type);
}
