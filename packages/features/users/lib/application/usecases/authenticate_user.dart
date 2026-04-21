import 'package:dartz/dartz.dart';
import 'package:foundation/foundation.dart';
import 'package:users/users.dart';

class AuthenticateUserParams {
  final String username;
  final String password;

  AuthenticateUserParams({
    required this.username,
    required this.password,
  });
}

class AuthenticateUserUseCase extends UseCase<User, AuthenticateUserParams> {
  final UserRepository repository;

  AuthenticateUserUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(AuthenticateUserParams params) async {
    final result = await repository.authenticate(params.username, params.password);
    
    if (result.isRight()) {
      return result;
    } else {
      return Left(Failure(message: 'Invalid username or password'));
    }
  }
}
