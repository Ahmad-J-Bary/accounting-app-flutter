import 'package:foundation/foundation.dart';
import '../../../domain/domain.dart';

/// نموذج حركة الأصول للتخزين في قاعدة البيانات
class AssetMovementModel {
  final String id;
  final String assetId;
  final String assetType; // 'fixed' or 'consumable'
  final String movementType; // AssetMovementType enum as string
  final String date; // ISO 8601 format
  final double? quantity; // للمستهلكات فقط
  final double amount;
  final String currencyCode;
  final double fxRate;
  final String fxRateDate;
  final String description;
  final String? referenceNo;
  final String? journalEntryId;
  final String? partnerId;
  final String? partnerName;
  final String? location;
  final String? notes;
  final int isPosted; // 1 = true, 0 = false
  final String createdAt;
  final String createdBy;

  const AssetMovementModel({
    required this.id,
    required this.assetId,
    required this.assetType,
    required this.movementType,
    required this.date,
    this.quantity,
    required this.amount,
    required this.currencyCode,
    required this.fxRate,
    required this.fxRateDate,
    required this.description,
    this.referenceNo,
    this.journalEntryId,
    this.partnerId,
    this.partnerName,
    this.location,
    this.notes,
    required this.isPosted,
    required this.createdAt,
    required this.createdBy,
  });

  factory AssetMovementModel.fromJson(Map<String, dynamic> json) {
    return AssetMovementModel(
      id: json['id'] as String,
      assetId: json['assetId'] as String,
      assetType: json['assetType'] as String,
      movementType: json['movementType'] as String,
      date: json['date'] as String,
      quantity: json['quantity'] != null ? (json['quantity'] as num).toDouble() : null,
      amount: (json['amount'] as num).toDouble(),
      currencyCode: json['currencyCode'] as String,
      fxRate: (json['fxRate'] as num).toDouble(),
      fxRateDate: json['fxRateDate'] as String,
      description: json['description'] as String,
      referenceNo: json['referenceNo'] as String?,
      journalEntryId: json['journalEntryId'] as String?,
      partnerId: json['partnerId'] as String?,
      partnerName: json['partnerName'] as String?,
      location: json['location'] as String?,
      notes: json['notes'] as String?,
      isPosted: json['isPosted'] as int,
      createdAt: json['createdAt'] as String,
      createdBy: json['createdBy'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assetId': assetId,
      'assetType': assetType,
      'movementType': movementType,
      'date': date,
      'quantity': quantity,
      'amount': amount,
      'currencyCode': currencyCode,
      'fxRate': fxRate,
      'fxRateDate': fxRateDate,
      'description': description,
      'referenceNo': referenceNo,
      'journalEntryId': journalEntryId,
      'partnerId': partnerId,
      'partnerName': partnerName,
      'location': location,
      'notes': notes,
      'isPosted': isPosted,
      'createdAt': createdAt,
      'createdBy': createdBy,
    };
  }

  /// تحويل من كيان المجال إلى نموذج
  factory AssetMovementModel.fromEntity(AssetMovement entity) {
    return AssetMovementModel(
      id: entity.id.value,
      assetId: entity.assetId.value,
      assetType: entity.assetType.name,
      movementType: entity.movementType.englishName,
      date: entity.date.toIso8601String(),
      quantity: entity.quantity?.value,
      amount: entity.amount.amount.toDouble(),
      currencyCode: entity.currency.code,
      fxRate: entity.fxRate.rate,
      fxRateDate: entity.fxRate.rateDate.toIso8601String(),
      description: entity.description,
      referenceNo: entity.referenceNo,
      journalEntryId: entity.journalEntryId?.value,
      partnerId: entity.partnerId?.value,
      partnerName: entity.partnerName,
      location: entity.location,
      notes: entity.notes,
      isPosted: entity.journalEntryId != null ? 1 : 0,
      createdAt: entity.createdAt.toIso8601String(),
      createdBy: entity.createdBy,
    );
  }

  /// تحويل النموذج إلى كيان المجال
  AssetMovement toEntity() {
    return AssetMovement(
      id: UniqueId.fromUniqueString(id),
      assetId: UniqueId.fromUniqueString(assetId),
      assetType: _parseAssetType(assetType),
      movementType: _parseMovementType(movementType),
      date: DateTime.parse(date),
      quantity: quantity != null
          ? Quantity(quantity!, 'unit') // الوحدة تُحصل من الأصل
          : null,
      amount: Money.fromDouble(amount, _parseCurrency(currencyCode)),
      currency: _parseCurrency(currencyCode),
      fxRate: MoneyFxRate(
        fromCurrency: _parseCurrency(currencyCode),
        toCurrency: Currency.syp(),
        rate: fxRate,
        rateDate: DateTime.parse(fxRateDate),
      ),
      description: description,
      referenceNo: referenceNo,
      journalEntryId: journalEntryId != null
          ? UniqueId.fromUniqueString(journalEntryId!)
          : null,
      partnerId: partnerId != null
          ? UniqueId.fromUniqueString(partnerId!)
          : null,
      partnerName: partnerName,
      location: location,
      notes: notes,
      createdAt: DateTime.parse(createdAt),
      createdBy: createdBy,
    );
  }

  Currency _parseCurrency(String code) {
    switch (code.toUpperCase()) {
      case 'SYP':
        return Currency.syp();
      case 'USD':
        return Currency.usd();
      default:
        return Currency(code: code, name: code, symbol: code);
    }
  }

  AssetType _parseAssetType(String type) {
    switch (type.toLowerCase()) {
      case 'fixed':
        return AssetType.fixed;
      case 'consumable':
        return AssetType.consumable;
      default:
        return AssetType.fixed;
    }
  }

  AssetMovementType _parseMovementType(String type) {
    switch (type.toLowerCase()) {
      case 'acquisition':
        return AssetMovementType.acquisition;
      case 'depreciation':
        return AssetMovementType.depreciation;
      case 'disposal':
        return AssetMovementType.disposal;
      case 'sale':
        return AssetMovementType.sale;
      case 'adjustment':
        return AssetMovementType.adjustment;
      case 'transfer':
        return AssetMovementType.transfer;
      case 'issue':
        return AssetMovementType.issue;
      case 'consumption':
        return AssetMovementType.consumption;
      case 'damage':
        return AssetMovementType.damage;
      case 'revaluation':
        return AssetMovementType.revaluation;
      case 'return':
        return AssetMovementType.return;
      default:
        return AssetMovementType.acquisition;
    }
  }
}
