import 'package:dartz/dartz.dart';
import 'package:foundation/foundation.dart';
import 'package:partners/partners.dart';

class CreatePartnerParams<T extends Partner> {
  final String code;
  final String name;
  final String? email;
  final String? phone;
  final String? address;
  final double creditLimit;
  final String? taxNumber;

  CreatePartnerParams({
    required this.code,
    required this.name,
    this.email,
    this.phone,
    this.address,
    this.creditLimit = 0,
    this.taxNumber,
  });
}

class CreatePartnerUseCase<T extends Partner> extends UseCase<T, CreatePartnerParams<T>> {
  final PartnerRepository<T> repository;

  CreatePartnerUseCase(this.repository);

  @override
  Future<Either<Failure, T>> call(CreatePartnerParams<T> params) async {
    // This will be implemented by specific use cases for Customer and Supplier
    throw UnimplementedError('Use CreateCustomerUseCase or CreateSupplierUseCase instead');
  }
}
