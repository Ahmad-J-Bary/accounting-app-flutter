import 'package:dartz/dartz.dart';
import 'package:foundation/foundation.dart';
import 'package:partners/partners.dart';

class DeleteCustomerUseCase extends UseCase<void, String> {
  final PartnerRepository<Customer> repository;

  DeleteCustomerUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String id) async {
    final customersResult = await repository.getAll();
    return customersResult.fold(
      (failure) => Left(failure),
      (customers) {
        final customer = customers.firstWhere(
          (c) => c.id.value == id,
          orElse: () => throw Exception('Customer not found'),
        );
        return repository.delete(customer.id);
      },
    );
  }
}
