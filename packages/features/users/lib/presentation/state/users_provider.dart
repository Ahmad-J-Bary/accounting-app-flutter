import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:platform/local_db/local_db.dart';
import 'package:users/users.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return UserRepositoryImpl(database);
});

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase.instance;
});

final createUserUseCaseProvider = Provider<CreateUserUseCase>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return CreateUserUseCase(repository);
});

final authenticateUserUseCaseProvider = Provider<AuthenticateUserUseCase>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return AuthenticateUserUseCase(repository);
});

final usersListProvider = FutureProvider<List<User>>((ref) async {
  final repository = ref.watch(userRepositoryProvider);
  final result = await repository.getAll();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (users) => users,
  );
});

final currentUserProvider = StateProvider<User?>((ref) => null);
