import 'package:equatable/equatable.dart';
import 'package:foundation/foundation.dart';

/// حركة على أصل (ثابت أو مستهلك)
/// تسجل كل عملية: شراء، اهلاك، استبعاد، صرف، استهلاك، إلخ
class AssetMovement extends Equatable {
  final UniqueId id;
  final UniqueId assetId;
  final AssetType assetType;
  final AssetMovementType movementType;
  final DateTime date;
  final Quantity? quantity;
  final Money amount;
  final Currency currency;
  final MoneyFxRate fxRate;
  final String description;
  final String? referenceNo;
  final UniqueId? journalEntryId;
  final UniqueId? partnerId;
  final String? partnerName;
  final String? location;
  final String? notes;
  final DateTime createdAt;
  final String createdBy;

  const AssetMovement({
    required this.id,
    required this.assetId,
    required this.assetType,
    required this.movementType,
    required this.date,
    this.quantity,
    required this.amount,
    required this.currency,
    required this.fxRate,
    required this.description,
    this.referenceNo,
    this.journalEntryId,
    this.partnerId,
    this.partnerName,
    this.location,
    this.notes,
    required this.createdAt,
    required this.createdBy,
  });

  AssetMovement copyWith({
    AssetMovementType? movementType,
    DateTime? date,
    Quantity? quantity,
    Money? amount,
    Currency? currency,
    MoneyFxRate? fxRate,
    String? description,
    String? referenceNo,
    UniqueId? journalEntryId,
    UniqueId? partnerId,
    String? partnerName,
    String? location,
    String? notes,
  }) {
    return AssetMovement(
      id: id,
      assetId: assetId,
      assetType: assetType,
      movementType: movementType ?? this.movementType,
      date: date ?? this.date,
      quantity: quantity ?? this.quantity,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      fxRate: fxRate ?? this.fxRate,
      description: description ?? this.description,
      referenceNo: referenceNo ?? this.referenceNo,
      journalEntryId: journalEntryId ?? this.journalEntryId,
      partnerId: partnerId ?? this.partnerId,
      partnerName: partnerName ?? this.partnerName,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      createdBy: createdBy,
    );
  }

  /// التحقق إذا كانت الحركة تؤثر على المخزون
  bool get affectsStock =>
      movementType == AssetMovementType.acquisition ||
      movementType == AssetMovementType.issue ||
      movementType == AssetMovementType.consumption ||
      movementType == AssetMovementType.adjustment ||
      movementType == AssetMovementType.damage;

  /// التحقق إذا كانت الحركة تحتاج إلى قيد محاسبي
  bool get requiresJournalEntry =>
      movementType == AssetMovementType.acquisition ||
      movementType == AssetMovementType.depreciation ||
      movementType == AssetMovementType.disposal ||
      movementType == AssetMovementType.sale ||
      movementType == AssetMovementType.revaluation ||
      movementType == AssetMovementType.issue ||
      movementType == AssetMovementType.consumption;

  @override
  List<Object?> get props => [
        id,
        assetId,
        assetType,
        movementType,
        date,
        amount,
        currency,
        journalEntryId,
      ];
}

/// نوع الأصل المرتبط بالحركة
enum AssetType {
  fixed,
  consumable,
}

/// نوع حركة الأصل
enum AssetMovementType {
  acquisition,    // شراء/إضافة
  depreciation,   // اهلاك
  disposal,     // استبعاد
  sale,         // بيع
  adjustment,   // تسوية
  transfer,     // نقل
  issue,        // صرف
  consumption,  // استهلاك
  damage,       // تلف
  revaluation,  // إعادة تقييم
  return,       // إرجاع
}

extension AssetMovementTypeExtension on AssetMovementType {
  String get displayName {
    switch (this) {
      case AssetMovementType.acquisition:
        return 'شراء/إضافة';
      case AssetMovementType.depreciation:
        return 'اهلاك';
      case AssetMovementType.disposal:
        return 'استبعاد';
      case AssetMovementType.sale:
        return 'بيع';
      case AssetMovementType.adjustment:
        return 'تسوية';
      case AssetMovementType.transfer:
        return 'نقل';
      case AssetMovementType.issue:
        return 'صرف';
      case AssetMovementType.consumption:
        return 'استهلاك';
      case AssetMovementType.damage:
        return 'تلف';
      case AssetMovementType.revaluation:
        return 'إعادة تقييم';
      case AssetMovementType.return:
        return 'إرجاع';
    }
  }

  String get englishName {
    switch (this) {
      case AssetMovementType.acquisition:
        return 'acquisition';
      case AssetMovementType.depreciation:
        return 'depreciation';
      case AssetMovementType.disposal:
        return 'disposal';
      case AssetMovementType.sale:
        return 'sale';
      case AssetMovementType.adjustment:
        return 'adjustment';
      case AssetMovementType.transfer:
        return 'transfer';
      case AssetMovementType.issue:
        return 'issue';
      case AssetMovementType.consumption:
        return 'consumption';
      case AssetMovementType.damage:
        return 'damage';
      case AssetMovementType.revaluation:
        return 'revaluation';
      case AssetMovementType.return:
        return 'return';
    }
  }
}
