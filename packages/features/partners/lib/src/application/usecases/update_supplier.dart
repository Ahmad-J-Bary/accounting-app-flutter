import 'package:dartz/dartz.dart';
import 'package:foundation/foundation.dart';
import 'package:partners/partners.dart';

class UpdateSupplierParams {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String? address;
  final bool isActive;

  UpdateSupplierParams({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.address,
    this.isActive = true,
  });
}

class UpdateSupplierUseCase extends UseCase<Supplier, UpdateSupplierParams> {
  final PartnerRepository<Supplier> repository;

  UpdateSupplierUseCase(this.repository);

  @override
  Future<Either<Failure, Supplier>> call(UpdateSupplierParams params) async {
    final suppliersResult = await repository.getAll();
    return suppliersResult.fold(
      (failure) => Left(failure),
      (suppliers) {
        final supplier = suppliers.firstWhere(
          (s) => s.id.value == params.id,
          orElse: () => throw Exception('Supplier not found'),
        );

        final updatedSupplier = supplier.copyWith(
          name: params.name,
          email: params.email,
          phone: params.phone,
          address: params.address,
          isActive: params.isActive,
          updatedAt: DateTime.now(),
        );

        return repository.update(updatedSupplier);
      },
    );
  }
}
