import 'package:dartz/dartz.dart';
import 'package:foundation/foundation.dart';
import 'package:partners/partners.dart';

class DeleteSupplierUseCase extends UseCase<void, String> {
  final PartnerRepository<Supplier> repository;

  DeleteSupplierUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String id) async {
    final suppliersResult = await repository.getAll();
    return suppliersResult.fold(
      (failure) => Left(failure),
      (suppliers) {
        final supplier = suppliers.firstWhere(
          (s) => s.id.value == id,
          orElse: () => throw Exception('Supplier not found'),
        );
        return repository.delete(supplier.id);
      },
    );
  }
}
