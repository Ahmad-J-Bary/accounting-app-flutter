import 'package:equatable/equatable.dart';
import 'package:shared/shared.dart';

enum JournalEntryType {
  sales,
  purchase,
  payment,
  receipt,
  adjustment,
  opening,
}

class JournalEntry extends Equatable {
  final UniqueId id;
  final String entryNumber;
  final DateTime entryDate;
  final JournalEntryType type;
  final String? reference;
  final String? description;
  final double totalDebit;
  final double totalCredit;
  final bool isPosted;
  final DateTime createdAt;
  final DateTime updatedAt;

  const JournalEntry({
    required this.id,
    required this.entryNumber,
    required this.entryDate,
    required this.type,
    this.reference,
    this.description,
    this.totalDebit = 0,
    this.totalCredit = 0,
    this.isPosted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isBalanced => totalDebit == totalCredit;

  @override
  List<Object?> get props => [
        id,
        entryNumber,
        entryDate,
        type,
        reference,
        description,
        totalDebit,
        totalCredit,
        isPosted,
        createdAt,
        updatedAt,
      ];
}
