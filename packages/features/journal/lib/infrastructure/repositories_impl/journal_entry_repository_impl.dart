import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import 'package:journal/journal.dart';

class JournalEntryRepositoryImpl implements JournalEntryRepository {
  final List<JournalEntry> _cache = [];

  @override
  Future<Either<Failure, JournalEntry>> getById(UniqueId id) async {
    try {
      final entry = _cache.firstWhere(
        (e) => e.id == id,
        orElse: () => throw Exception('Journal entry not found'),
      );
      return Right(entry);
    } catch (e) {
      return Left(NotFoundFailure('Journal entry not found'));
    }
  }

  @override
  Future<Either<Failure, List<JournalEntry>>> getAll() async {
    try {
      return Right(_cache);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, JournalEntry>> create(JournalEntry entity) async {
    try {
      _cache.add(entity);
      return Right(entity);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, JournalEntry>> update(JournalEntry entity) async {
    try {
      final index = _cache.indexWhere((e) => e.id == entity.id);
      if (index == -1) {
        return Left(NotFoundFailure('Journal entry not found'));
      }
      _cache[index] = entity;
      return Right(entity);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> delete(UniqueId id) async {
    try {
      _cache.removeWhere((e) => e.id == id);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<JournalEntry>>> getByDateRange(DateTime start, DateTime end) async {
    try {
      final filtered = _cache
          .where((e) => e.entryDate.isAfter(start) && e.entryDate.isBefore(end))
          .toList();
      return Right(filtered);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<JournalEntry>>> getByType(JournalEntryType type) async {
    try {
      final filtered = _cache.where((e) => e.type == type).toList();
      return Right(filtered);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, JournalEntry>> getByNumber(String entryNumber) async {
    try {
      final entry = _cache.firstWhere(
        (e) => e.entryNumber == entryNumber,
        orElse: () => throw Exception('Journal entry not found'),
      );
      return Right(entry);
    } catch (e) {
      return Left(NotFoundFailure('Journal entry with number $entryNumber not found'));
    }
  }

  @override
  Future<Either<Failure, Unit>> postEntry(UniqueId id) async {
    try {
      final index = _cache.indexWhere((e) => e.id == id);
      if (index == -1) {
        return Left(NotFoundFailure('Journal entry not found'));
      }
      _cache[index] = JournalEntry(
        id: _cache[index].id,
        entryNumber: _cache[index].entryNumber,
        entryDate: _cache[index].entryDate,
        type: _cache[index].type,
        reference: _cache[index].reference,
        description: _cache[index].description,
        totalDebit: _cache[index].totalDebit,
        totalCredit: _cache[index].totalCredit,
        isPosted: true,
        createdAt: _cache[index].createdAt,
        updatedAt: DateTime.now(),
      );
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> reverseEntry(UniqueId id) async {
    try {
      final index = _cache.indexWhere((e) => e.id == id);
      if (index == -1) {
        return Left(NotFoundFailure('Journal entry not found'));
      }
      _cache.removeAt(index);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
