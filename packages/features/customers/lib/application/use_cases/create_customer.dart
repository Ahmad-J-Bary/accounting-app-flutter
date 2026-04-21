import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import 'package:customers/customers.dart';

class CreateCustomerParams {
  final String code;
  final String name;
  final String? email;
  final String? phone;
  final String? address;
  final double creditLimit;

  const CreateCustomerParams({
    required this.code,
    required this.name,
    this.email,
    this.phone,
    this.address,
    this.creditLimit = 0,
  });
}

class CreateCustomerUseCase extends UseCase<Customer, CreateCustomerParams> {
  final CustomerRepository repository;

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
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    return repository.create(customer);
  }
}
