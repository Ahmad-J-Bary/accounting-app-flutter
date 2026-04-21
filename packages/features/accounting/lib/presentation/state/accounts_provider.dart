import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:accounting/accounting.dart';
import 'package:accounting/application/use_cases/create_account.dart';
import 'package:accounting/application/use_cases/get_accounts.dart';
import 'package:accounting/data/repositories_impl/account_repository_impl.dart';

// Repository Provider
final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  return AccountRepositoryImpl(
    localDataSource: AccountLocalDataSourceImpl(),
    remoteDataSource: AccountRemoteDataSourceImpl(),
  );
});

// Use Case Providers
final createAccountUseCaseProvider = Provider<CreateAccountUseCase>((ref) {
  final repository = ref.watch(accountRepositoryProvider);
  return CreateAccountUseCase(repository);
});

final getAccountsUseCaseProvider = Provider<GetAccountsUseCaseProvider>((ref) {
  final repository = ref.watch(accountRepositoryProvider);
  return GetAccountsUseCaseProvider(repository);
});

final getAccountsByTypeUseCaseProvider = Provider<GetAccountsByTypeUseCase>((ref) {
  final repository = ref.watch(accountRepositoryProvider);
  return GetAccountsByTypeUseCase(repository);
});

// State Providers
final accountsListProvider = FutureProvider.autoDispose<List<Account>>((ref) async {
  final useCase = ref.watch(getAccountsUseCaseProvider);
  final result = await useCase(const NoParams());
  return result.fold(
    (failure) => throw Exception(failure.toString()),
    (accounts) => accounts,
  );
});

final selectedAccountTypeProvider = StateProvider<AccountType?>((ref) => null);

final accountsByTypeProvider = FutureProvider.autoDispose<List<Account>>((ref) async {
  final type = ref.watch(selectedAccountTypeProvider);
  if (type == null) return [];
  final useCase = ref.watch(getAccountsByTypeUseCaseProvider);
  final result = await useCase(GetAccountsByTypeParams(type: type));
  return result.fold(
    (failure) => throw Exception(failure.toString()),
    (accounts) => accounts,
  );
});
