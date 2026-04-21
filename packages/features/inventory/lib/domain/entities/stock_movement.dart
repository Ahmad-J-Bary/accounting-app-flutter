import 'package:equatable/equatable.dart';
import 'package:shared/shared.dart';

enum MovementType {
  purchase,
  sale,
  transfer,
  adjustment,
  production,
  damage,
  returnIn,
  returnOut,
}

class StockMovement extends Equatable {
  final UniqueId id;
  final String movementNumber;
  final DateTime movementDate;
  final MovementType type;
  final UniqueId productId;
  final String productName;
  final UniqueId warehouseId;
  final String warehouseName;
  final double quantity;
  final double unitCost;
  final double totalCost;
  final String? reference;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StockMovement({
    required this.id,
    required this.movementNumber,
    required this.movementDate,
    required this.type,
    required this.productId,
    required this.productName,
    required this.warehouseId,
    required this.warehouseName,
    required this.quantity,
    required this.unitCost,
    required this.totalCost,
    this.reference,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        movementNumber,
        movementDate,
        type,
        productId,
        productName,
        warehouseId,
        warehouseName,
        quantity,
        unitCost,
        totalCost,
        reference,
        notes,
        createdAt,
        updatedAt,
      ];
}
