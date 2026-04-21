import 'package:dartz/dartz.dart';
import 'package:platform/local_db/local_db.dart';
import 'package:foundation/foundation.dart';
import 'package:partners/partners.dart';

class CustomerRepositoryImpl implements PartnerRepository<Customer> {
  final AppDatabase database;
  final Map<UniqueId, Customer> _cache = {};

  CustomerRepositoryImpl(this.database);

  @override
  Future<Either<Failure, Customer>> getById(UniqueId id) async {
    try {
      final cached = _cache[id];
      if (cached != null) return Right(cached);

      // In production, query from database
      final customer = Customer(
        id: id,
        code: 'CUST001',
        name: 'Sample Customer',
        email: 'customer@example.com',
        phone: '+1234567890',
        address: '123 Main St',
        creditLimit: 10000,
        currentBalance: 0,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _cache[id] = customer;
      return Right(customer);
    } catch (e) {
      return Left(Failure(message: 'Failed to get customer: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Customer>>> getAll() async {
    try {
      if (_cache.isNotEmpty) return Right(_cache.values.toList());

      // Return sample data
      final customers = [
        Customer(
          id: UniqueId(),
          code: 'CUST001',
          name: 'John Doe',
          email: 'john@example.com',
          phone: '+1234567890',
          address: '123 Main St',
          creditLimit: 10000,
          currentBalance: 2500,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Customer(
          id: UniqueId(),
          code: 'CUST002',
          name: 'Jane Smith',
          email: 'jane@example.com',
          phone: '+0987654321',
          address: '456 Oak Ave',
          creditLimit: 15000,
          currentBalance: 5000,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
      for (var customer in customers) {
        _cache[customer.id] = customer;
      }
      return Right(customers);
    } catch (e) {
      return Left(Failure(message: 'Failed to get customers: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Customer>> create(Customer entity) async {
    try {
      _cache[entity.id] = entity;
      return Right(entity);
    } catch (e) {
      return Left(Failure(message: 'Failed to create customer: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Customer>> update(Customer entity) async {
    try {
      _cache[entity.id] = entity.copyWith(updatedAt: DateTime.now());
      return Right(_cache[entity.id]!);
    } catch (e) {
      return Left(Failure(message: 'Failed to update customer: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> delete(UniqueId id) async {
    try {
      _cache.remove(id);
      return const Right(unit);
    } catch (e) {
      return Left(Failure(message: 'Failed to delete customer: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Customer>> getByCode(String code) async {
    try {
      final customers = await getAll();
      return customers.fold(
        (failure) => Left(failure),
        (customers) {
          final customer = customers.firstWhere(
            (c) => c.code.toLowerCase() == code.toLowerCase(),
            orElse: () => throw Exception('Customer not found'),
          );
          return Right(customer);
        },
      );
    } catch (e) {
      return Left(Failure(message: 'Customer not found: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Customer>>> search(String query) async {
    try {
      final customers = await getAll();
      return customers.fold(
        (failure) => Left(failure),
        (customers) {
          final filtered = customers.where((c) =>
              c.code.toLowerCase().contains(query.toLowerCase()) ||
              c.name.toLowerCase().contains(query.toLowerCase()) ||
              (c.email?.toLowerCase().contains(query.toLowerCase()) ?? false)
          ).toList();
          return Right(filtered);
        },
      );
    } catch (e) {
      return Left(Failure(message: 'Failed to search customers: ${e.toString()}'));
    }
  }
}
