import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import 'package:inventory/inventory.dart';

class CreateWarehouseParams {
  final String code;
  final String name;
  final String? address;
  final String? phone;
  final String? manager;

  CreateWarehouseParams({
    required this.code,
    required this.name,
    this.address,
    this.phone,
    this.manager,
  });
}

class CreateWarehouseUseCase extends UseCase<Warehouse, CreateWarehouseParams> {
  final WarehouseRepository repository;

  CreateWarehouseUseCase(this.repository);

  @override
  Future<Either<Failure, Warehouse>> call(CreateWarehouseParams params) async {
    final warehouse = Warehouse(
      id: UniqueId(),
      code: params.code,
      name: params.name,
      address: params.address,
      phone: params.phone,
      manager: params.manager,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return await repository.create(warehouse);
  }
}
