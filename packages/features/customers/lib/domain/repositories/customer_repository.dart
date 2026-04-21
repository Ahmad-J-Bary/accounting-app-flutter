import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import 'package:customers/customers.dart';

abstract class CustomerRepository extends Repository<Customer, UniqueId> {
  Future<Either<Failure, List<Customer>> search(String query);
  Future<Either<Failure, Customer>> getByCode(String code);
}
