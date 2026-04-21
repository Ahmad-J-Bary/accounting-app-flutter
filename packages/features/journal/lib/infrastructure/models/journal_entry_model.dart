import 'package:journal/journal.dart';
import 'dart:convert';

class JournalEntryModel {
  final String id;
  final String entryNumber;
  final String entryDate;
  final String type;
  final String? reference;
  final String? description;
  final double totalDebit;
  final double totalCredit;
  final bool isPosted;
  final String createdAt;
  final String updatedAt;

  JournalEntryModel({
    required this.id,
    required this.entryNumber,
    required this.entryDate,
    required this.type,
    this.reference,
    this.description,
    required this.totalDebit,
    required this.totalCredit,
    required this.isPosted,
    required this.createdAt,
    required this.updatedAt,
  });

  factory JournalEntryModel.fromJson(Map<String, dynamic> json) {
    return JournalEntryModel(
      id: json['id'] as String,
      entryNumber: json['entryNumber'] as String,
      entryDate: json['entryDate'] as String,
      type: json['type'] as String,
      reference: json['reference'] as String?,
      description: json['description'] as String?,
      totalDebit: (json['totalDebit'] as num).toDouble(),
      totalCredit: (json['totalCredit'] as num).toDouble(),
      isPosted: json['isPosted'] as bool,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entryNumber': entryNumber,
      'entryDate': entryDate,
      'type': type,
      if (reference != null) 'reference': reference,
      if (description != null) 'description': description,
      'totalDebit': totalDebit,
      'totalCredit': totalCredit,
      'isPosted': isPosted,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  static JournalEntryModel fromEntity(JournalEntry entity) {
    return JournalEntryModel(
      id: entity.id.value,
      entryNumber: entity.entryNumber,
      entryDate: entity.entryDate.toIso8601String(),
      type: entity.type.name,
      reference: entity.reference,
      description: entity.description,
      totalDebit: entity.totalDebit,
      totalCredit: entity.totalCredit,
      isPosted: entity.isPosted,
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt.toIso8601String(),
    );
  }

  JournalEntry toEntity() {
    return JournalEntry(
      id: UniqueId.fromUniqueString(id),
      entryNumber: entryNumber,
      entryDate: DateTime.parse(entryDate),
      type: JournalEntryType.values.firstWhere((e) => e.name == type),
      reference: reference,
      description: description,
      totalDebit: totalDebit,
      totalCredit: totalCredit,
      isPosted: isPosted,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }
}
