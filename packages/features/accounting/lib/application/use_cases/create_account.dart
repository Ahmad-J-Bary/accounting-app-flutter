import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import 'package:accounting/accounting.dart';

class CreateAccountParams {
  final String code;
  final String name;
  final String? description;
  final AccountType type;
  final UniqueId? parentId;

  const CreateAccountParams({
    required this.code,
    required this.name,
    this.description,
    required this.type,
    this.parentId,
  });
}

class CreateAccountUseCase extends UseCase<Account, CreateAccountParams> {
  final AccountRepository repository;

  CreateAccountUseCase(this.repository);

  @override
  Future<Either<Failure, Account>> call(CreateAccountParams params) async {
    final account = Account(
      id: UniqueId(),
      code: params.code,
      name: params.name,
      description: params.description,
      type: params.type,
      parentId: params.parentId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    return repository.create(account);
  }
}
