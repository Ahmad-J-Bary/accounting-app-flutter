import 'package:dartz/dartz.dart';
import 'package:platform/local_db/local_db.dart';
import 'package:foundation/foundation.dart';
import 'package:users/users.dart';

class UserRepositoryImpl implements UserRepository {
  final AppDatabase database;
  final Map<UniqueId, User> _cache = {};

  UserRepositoryImpl(this.database);

  @override
  Future<Either<Failure, User>> getById(UniqueId id) async {
    try {
      final cached = _cache[id];
      if (cached != null) return Right(cached);

      // In production, query from database
      final user = User(
        id: id,
        username: 'admin',
        email: 'admin@example.com',
        fullName: 'Admin User',
        role: UserRole.admin,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _cache[id] = user;
      return Right(user);
    } catch (e) {
      return Left(Failure(message: 'Failed to get user: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<User>>> getAll() async {
    try {
      if (_cache.isNotEmpty) return Right(_cache.values.toList());

      // Return sample data
      final users = [
        User(
          id: UniqueId(),
          username: 'admin',
          email: 'admin@example.com',
          fullName: 'Admin User',
          role: UserRole.admin,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
      for (var user in users) {
        _cache[user.id] = user;
      }
      return Right(users);
    } catch (e) {
      return Left(Failure(message: 'Failed to get users: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> create(User entity) async {
    try {
      _cache[entity.id] = entity;
      // In production, insert into database
      return Right(entity);
    } catch (e) {
      return Left(Failure(message: 'Failed to create user: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> update(User entity) async {
    try {
      _cache[entity.id] = entity.copyWith(updatedAt: DateTime.now());
      // In production, update in database
      return Right(_cache[entity.id]!);
    } catch (e) {
      return Left(Failure(message: 'Failed to update user: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> delete(UniqueId id) async {
    try {
      _cache.remove(id);
      // In production, delete from database
      return const Right(unit);
    } catch (e) {
      return Left(Failure(message: 'Failed to delete user: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> getByUsername(String username) async {
    try {
      final users = await getAll();
      return users.fold(
        (failure) => Left(failure),
        (users) {
          final user = users.firstWhere(
            (u) => u.username.toLowerCase() == username.toLowerCase(),
            orElse: () => throw Exception('User not found'),
          );
          return Right(user);
        },
      );
    } catch (e) {
      return Left(Failure(message: 'User not found: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> getByEmail(String email) async {
    try {
      final users = await getAll();
      return users.fold(
        (failure) => Left(failure),
        (users) {
          final user = users.firstWhere(
            (u) => u.email.toLowerCase() == email.toLowerCase(),
            orElse: () => throw Exception('User not found'),
          );
          return Right(user);
        },
      );
    } catch (e) {
      return Left(Failure(message: 'User not found: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<User>>> search(String query) async {
    try {
      final users = await getAll();
      return users.fold(
        (failure) => Left(failure),
        (users) {
          final filtered = users.where((u) =>
              u.username.toLowerCase().contains(query.toLowerCase()) ||
              u.email.toLowerCase().contains(query.toLowerCase()) ||
              u.fullName.toLowerCase().contains(query.toLowerCase())
          ).toList();
          return Right(filtered);
        },
      );
    } catch (e) {
      return Left(Failure(message: 'Failed to search users: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> authenticate(String username, String password) async {
    try {
      final userResult = await getByUsername(username);
      return userResult.fold(
        (failure) => Left(failure),
        (user) {
          // In production, verify password hash
          // For now, accept any password for demo
          if (user.isActive) {
            return Right(true);
          }
          return Left(Failure(message: 'User is inactive'));
        },
      );
    } catch (e) {
      return Left(Failure(message: 'Authentication failed: ${e.toString()}'));
    }
  }
}
