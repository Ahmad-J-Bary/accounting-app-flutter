import 'package:dartz/dartz.dart';
import 'package:foundation/foundation.dart';
import 'package:partners/partners.dart';

class UpdateCustomerParams {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String? address;
  final bool isActive;

  UpdateCustomerParams({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.address,
    this.isActive = true,
  });
}

class UpdateCustomerUseCase extends UseCase<Customer, UpdateCustomerParams> {
  final PartnerRepository<Customer> repository;

  UpdateCustomerUseCase(this.repository);

  @override
  Future<Either<Failure, Customer>> call(UpdateCustomerParams params) async {
    final customersResult = await repository.getAll();
    return customersResult.fold(
      (failure) => Left(failure),
      (customers) {
        final customer = customers.firstWhere(
          (c) => c.id.value == params.id,
          orElse: () => throw Exception('Customer not found'),
        );

        final updatedCustomer = customer.copyWith(
          name: params.name,
          email: params.email,
          phone: params.phone,
          address: params.address,
          isActive: params.isActive,
          updatedAt: DateTime.now(),
        );

        return repository.update(updatedCustomer);
      },
    );
  }
}
