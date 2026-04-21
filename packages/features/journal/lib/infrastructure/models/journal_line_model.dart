import 'package:journal/journal.dart';
import 'dart:convert';

class JournalLineModel {
  final String id;
  final String entryId;
  final String accountId;
  final String accountName;
  final String accountCode;
  final double debit;
  final double credit;
  final String? description;

  JournalLineModel({
    required this.id,
    required this.entryId,
    required this.accountId,
    required this.accountName,
    required this.accountCode,
    required this.debit,
    required this.credit,
    this.description,
  });

  factory JournalLineModel.fromJson(Map<String, dynamic> json) {
    return JournalLineModel(
      id: json['id'] as String,
      entryId: json['entryId'] as String,
      accountId: json['accountId'] as String,
      accountName: json['accountName'] as String,
      accountCode: json['accountCode'] as String,
      debit: (json['debit'] as num).toDouble(),
      credit: (json['credit'] as num).toDouble(),
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entryId': entryId,
      'accountId': accountId,
      'accountName': accountName,
      'accountCode': accountCode,
      'debit': debit,
      'credit': credit,
      if (description != null) 'description': description,
    };
  }

  static JournalLineModel fromEntity(JournalLine entity) {
    return JournalLineModel(
      id: entity.id.value,
      entryId: entity.entryId.value,
      accountId: entity.accountId.value,
      accountName: entity.accountName,
      accountCode: entity.accountCode,
      debit: entity.debit,
      credit: entity.credit,
      description: entity.description,
    );
  }

  JournalLine toEntity() {
    return JournalLine(
      id: UniqueId.fromUniqueString(id),
      entryId: UniqueId.fromUniqueString(entryId),
      accountId: UniqueId.fromUniqueString(accountId),
      accountName: accountName,
      accountCode: accountCode,
      debit: debit,
      credit: credit,
      description: description,
    );
  }
}
