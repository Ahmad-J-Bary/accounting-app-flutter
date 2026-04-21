import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import 'package:journal/journal.dart';

abstract class JournalEntryRepository extends Repository<JournalEntry, UniqueId> {
  Future<Either<Failure, List<JournalEntry>> getByDateRange(DateTime start, DateTime end);
  Future<Either<Failure, List<JournalEntry>> getByType(JournalEntryType type);
  Future<Either<Failure, JournalEntry>> getByNumber(String entryNumber);
  Future<Either<Failure, Unit>> postEntry(UniqueId id);
  Future<Either<Failure, Unit>> reverseEntry(UniqueId id);
}
