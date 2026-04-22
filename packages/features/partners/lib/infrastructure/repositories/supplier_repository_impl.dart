import 'package:dartz/dartz.dart';
import 'package:foundation/foundation.dart';
import 'package:partners/partners.dart';
import 'package:partners/infrastructure/database/app_database.dart';
import 'package:sqflite/sqflite.dart';

class SupplierRepositoryImpl implements PartnerRepository<Supplier> {
  final AppDatabase database;
  final Map<UniqueId, Supplier> _cache = {};

  SupplierRepositoryImpl(this.database);

  @override
  Future<Either<Failure, Supplier>> getById(UniqueId id) async {
    try {
      final cached = _cache[id];
      if (cached != null) return Right(cached);

      // In production, query from database
      final supplier = Supplier(
        id: id,
        code: 'SUPP001',
        name: 'Sample Supplier',
        email: 'supplier@example.com',
        phone: '+1234567890',
        address: '789 Supplier Rd',
        creditLimit: 20000,
        currentBalance: 0,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _cache[id] = supplier;
      return Right(supplier);
    } catch (e) {
      return Left(GenericFailure('Failed to get supplier: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Supplier>>> getAll() async {
    try {
      if (_cache.isNotEmpty) return Right(_cache.values.toList());

      // Return sample data
      final suppliers = [
        Supplier(
          id: UniqueId(),
          code: 'SUPP001',
          name: 'ABC Supplies',
          email: 'abc@supplies.com',
          phone: '+1111111111',
          address: '111 Supplier St',
          creditLimit: 50000,
          currentBalance: 10000,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Supplier(
          id: UniqueId(),
          code: 'SUPP002',
          name: 'XYZ Materials',
          email: 'xyz@materials.com',
          phone: '+2222222222',
          address: '222 Material Ave',
          creditLimit: 30000,
          currentBalance: 5000,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
      for (var supplier in suppliers) {
        _cache[supplier.id] = supplier;
      }
      return Right(suppliers);
    } catch (e) {
      return Left(GenericFailure('Failed to get suppliers: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Supplier>> create(Supplier entity) async {
    try {
      _cache[entity.id] = entity;
      return Right(entity);
    } catch (e) {
      return Left(GenericFailure('Failed to create supplier: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Supplier>> update(Supplier entity) async {
    try {
      _cache[entity.id] = entity.copyWith(updatedAt: DateTime.now());
      return Right(_cache[entity.id]!);
    } catch (e) {
      return Left(GenericFailure('Failed to update supplier: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> delete(UniqueId id) async {
    try {
      _cache.remove(id);
      return const Right(unit);
    } catch (e) {
      return Left(GenericFailure('Failed to delete supplier: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Supplier>> getByCode(String code) async {
    try {
      final suppliers = await getAll();
      return suppliers.fold(
        (failure) => Left(failure),
        (suppliers) {
          final supplier = suppliers.firstWhere(
            (s) => s.code.toLowerCase() == code.toLowerCase(),
            orElse: () => throw Exception('Supplier not found'),
          );
          return Right(supplier);
        },
      );
    } catch (e) {
      return Left(GenericFailure('Supplier not found: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Supplier>>> search(String query) async {
    try {
      final suppliers = await getAll();
      return suppliers.fold(
        (failure) => Left(failure),
        (suppliers) {
          final filtered = suppliers.where((s) =>
              s.code.toLowerCase().contains(query.toLowerCase()) ||
              s.name.toLowerCase().contains(query.toLowerCase()) ||
              (s.email?.toLowerCase().contains(query.toLowerCase()) ?? false)
          ).toList();
          return Right(filtered);
        },
      );
    } catch (e) {
      return Left(GenericFailure('Failed to search suppliers: ${e.toString()}'));
    }
  }
}
