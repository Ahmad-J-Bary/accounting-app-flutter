import 'package:equatable/equatable.dart';
import 'package:shared/shared.dart';

class JournalLine extends Equatable {
  final UniqueId id;
  final UniqueId entryId;
  final UniqueId accountId;
  final String accountName;
  final String accountCode;
  final double debit;
  final double credit;
  final String? description;

  const JournalLine({
    required this.id,
    required this.entryId,
    required this.accountId,
    required this.accountName,
    required this.accountCode,
    this.debit = 0,
    this.credit = 0,
    this.description,
  });

  @override
  List<Object?> get props => [
        id,
        entryId,
        accountId,
        accountName,
        accountCode,
        debit,
        credit,
        description,
      ];
}
