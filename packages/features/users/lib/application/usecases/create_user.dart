import 'package:dartz/dartz.dart';
import 'package:foundation/foundation.dart';
import 'package:users/users.dart';

class CreateUserParams {
  final String username;
  final String email;
  final String fullName;
  final String? phone;
  final UserRole role;
  final String password;

  CreateUserParams({
    required this.username,
    required this.email,
    required this.fullName,
    this.phone,
    this.role = UserRole.viewer,
    required this.password,
  });
}

class CreateUserUseCase extends UseCase<User, CreateUserParams> {
  final UserRepository repository;

  CreateUserUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(CreateUserParams params) async {
    final user = User(
      id: UniqueId(),
      username: params.username,
      email: params.email,
      fullName: params.fullName,
      phone: params.phone,
      role: params.role,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return await repository.create(user);
  }
}
