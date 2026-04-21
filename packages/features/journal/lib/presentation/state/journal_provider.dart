import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journal/journal.dart';
import 'package:journal/application/use_cases/create_journal_entry.dart';
import 'package:journal/data/repositories_impl/journal_entry_repository_impl.dart';

// Repository Provider
final journalEntryRepositoryProvider = Provider<JournalEntryRepository>((ref) {
  return JournalEntryRepositoryImpl();
});

// Use Case Providers
final createJournalEntryUseCaseProvider = Provider<CreateJournalEntryUseCase>((ref) {
  final repository = ref.watch(journalEntryRepositoryProvider);
  return CreateJournalEntryUseCase(repository);
});

// State Providers
final journalEntriesListProvider = FutureProvider.autoDispose<List<JournalEntry>>((ref) async {
  final repository = ref.watch(journalEntryRepositoryProvider);
  final result = await repository.getAll();
  return result.fold(
    (failure) => throw Exception(failure.toString()),
    (entries) => entries,
  );
});
