import 'package:dartz/dartz.dart';
import 'package:foundation/foundation.dart';
import 'package:users/users.dart';

abstract class UserRepository extends Repository<User, UniqueId> {
  Future<Either<Failure, User>> getByUsername(String username);
  Future<Either<Failure, User>> getByEmail(String email);
  Future<Either<Failure, List<User>>> search(String query);
  Future<Either<Failure, bool>> authenticate(String username, String password);
}
