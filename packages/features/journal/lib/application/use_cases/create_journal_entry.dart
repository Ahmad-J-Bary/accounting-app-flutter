import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import 'package:journal/journal.dart';

class CreateJournalEntryParams {
  final String entryNumber;
  final DateTime entryDate;
  final JournalEntryType type;
  final String? reference;
  final String? description;
  final List<JournalLine> lines;

  const CreateJournalEntryParams({
    required this.entryNumber,
    required this.entryDate,
    required this.type,
    this.reference,
    this.description,
    required this.lines,
  });
}

class CreateJournalEntryUseCase extends UseCase<JournalEntry, CreateJournalEntryParams> {
  final JournalEntryRepository repository;

  CreateJournalEntryUseCase(this.repository);

  @override
  Future<Either<Failure, JournalEntry>> call(CreateJournalEntryParams params) async {
    final totalDebit = params.lines.fold<double>(0, (sum, line) => sum + line.debit);
    final totalCredit = params.lines.fold<double>(0, (sum, line) => sum + line.credit);

    if (totalDebit != totalCredit) {
      return const Left(ValidationFailure('Journal entry must be balanced'));
    }

    final entry = JournalEntry(
      id: UniqueId(),
      entryNumber: params.entryNumber,
      entryDate: params.entryDate,
      type: params.type,
      reference: params.reference,
      description: params.description,
      totalDebit: totalDebit,
      totalCredit: totalCredit,
      isPosted: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    return repository.create(entry);
  }
}
