import 'package:dartz/dartz.dart';
import 'package:foundation/foundation.dart';
import 'package:partners/partners.dart';

abstract class PartnerRepository<T extends Partner> extends Repository<T, UniqueId> {
  Future<Either<Failure, T>> getByCode(String code);
  Future<Either<Failure, List<T>>> search(String query);
}
