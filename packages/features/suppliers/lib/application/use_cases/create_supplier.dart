import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import 'package:suppliers/suppliers.dart';

class CreateSupplierParams {
  final String code;
  final String name;
  final String? email;
  final String? phone;
  final String? address;
  final String? taxNumber;
  final double creditLimit;

  CreateSupplierParams({
    required this.code,
    required this.name,
    this.email,
    this.phone,
    this.address,
    this.taxNumber,
    this.creditLimit = 0,
  });
}

class CreateSupplierUseCase extends UseCase<Supplier, CreateSupplierParams> {
  final SupplierRepository repository;

  CreateSupplierUseCase(this.repository);

  @override
  Future<Either<Failure, Supplier>> call(CreateSupplierParams params) async {
    final supplier = Supplier(
      id: UniqueId(),
      code: params.code,
      name: params.name,
      email: params.email,
      phone: params.phone,
      address: params.address,
      taxNumber: params.taxNumber,
      creditLimit: params.creditLimit,
      currentBalance: 0,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return await repository.create(supplier);
  }
}
