import 'package:dartz/dartz.dart';
import 'package:foundation/foundation.dart';
import 'package:partners/partners.dart';

class CreateCustomerParams {
  final String code;
  final String name;
  final String? email;
  final String? phone;
  final String? address;
  final double creditLimit;
  final String? taxNumber;

  CreateCustomerParams({
    required this.code,
    required this.name,
    this.email,
    this.phone,
    this.address,
    this.creditLimit = 0,
    this.taxNumber,
  });
}

class CreateCustomerUseCase extends UseCase<Customer, CreateCustomerParams> {
  final PartnerRepository<Customer> repository;

  CreateCustomerUseCase(this.repository);

  @override
  Future<Either<Failure, Customer>> call(CreateCustomerParams params) async {
    final customer = Customer(
      id: UniqueId(),
      code: params.code,
      name: params.name,
      email: params.email,
      phone: params.phone,
      address: params.address,
      creditLimit: params.creditLimit,
      currentBalance: 0,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      taxNumber: params.taxNumber,
    );

    return await repository.create(customer);
  }
}
