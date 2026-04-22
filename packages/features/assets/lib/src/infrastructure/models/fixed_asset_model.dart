import 'package:foundation/foundation.dart';
import '../../../domain/domain.dart';

/// نموذج الأصل الثابت للتخزين في قاعدة البيانات
class FixedAssetModel {
  final String id;
  final String code;
  final String name;
  final String categoryId;
  final String? categoryName;
  final String purchaseDate; // ISO 8601 format
  final double purchaseCost;
  final String currencyCode;
  final double fxRate;
  final String fxRateDate;
  final int usefulLifeMonths;
  final double? salvageValue;
  final double accumulatedDepreciation;
  final double netBookValue;
  final String status; // AssetStatus enum as string
  final String? location;
  final String? notes;
  final int isActive; // 1 = true, 0 = false
  final String createdAt;
  final String updatedAt;
  final String? journalEntryId;

  const FixedAssetModel({
    required this.id,
    required this.code,
    required this.name,
    required this.categoryId,
    this.categoryName,
    required this.purchaseDate,
    required this.purchaseCost,
    required this.currencyCode,
    required this.fxRate,
    required this.fxRateDate,
    required this.usefulLifeMonths,
    this.salvageValue,
    required this.accumulatedDepreciation,
    required this.netBookValue,
    required this.status,
    this.location,
    this.notes,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.journalEntryId,
  });

  factory FixedAssetModel.fromJson(Map<String, dynamic> json) {
    return FixedAssetModel(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      categoryId: json['categoryId'] as String,
      categoryName: json['categoryName'] as String?,
      purchaseDate: json['purchaseDate'] as String,
      purchaseCost: (json['purchaseCost'] as num).toDouble(),
      currencyCode: json['currencyCode'] as String,
      fxRate: (json['fxRate'] as num).toDouble(),
      fxRateDate: json['fxRateDate'] as String,
      usefulLifeMonths: json['usefulLifeMonths'] as int,
      salvageValue: json['salvageValue'] != null ? (json['salvageValue'] as num).toDouble() : null,
      accumulatedDepreciation: (json['accumulatedDepreciation'] as num).toDouble(),
      netBookValue: (json['netBookValue'] as num).toDouble(),
      status: json['status'] as String,
      location: json['location'] as String?,
      notes: json['notes'] as String?,
      isActive: json['isActive'] as int,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      journalEntryId: json['journalEntryId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'purchaseDate': purchaseDate,
      'purchaseCost': purchaseCost,
      'currencyCode': currencyCode,
      'fxRate': fxRate,
      'fxRateDate': fxRateDate,
      'usefulLifeMonths': usefulLifeMonths,
      'salvageValue': salvageValue,
      'accumulatedDepreciation': accumulatedDepreciation,
      'netBookValue': netBookValue,
      'status': status,
      'location': location,
      'notes': notes,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'journalEntryId': journalEntryId,
    };
  }

  /// تحويل من كيان المجال إلى نموذج
  factory FixedAssetModel.fromEntity(FixedAsset entity) {
    return FixedAssetModel(
      id: entity.id.value,
      code: entity.code,
      name: entity.name,
      categoryId: entity.categoryId.value,
      categoryName: entity.categoryName,
      purchaseDate: entity.purchaseDate.toIso8601String(),
      purchaseCost: entity.purchaseCost.amount.toDouble(),
      currencyCode: entity.currency.code,
      fxRate: entity.fxRate.rate,
      fxRateDate: entity.fxRate.rateDate.toIso8601String(),
      usefulLifeMonths: entity.usefulLifeMonths,
      salvageValue: entity.salvageValue?.amount.toDouble(),
      accumulatedDepreciation: entity.accumulatedDepreciation.amount.toDouble(),
      netBookValue: entity.netBookValue.amount.toDouble(),
      status: entity.status.englishName,
      location: entity.location,
      notes: entity.notes,
      isActive: entity.isActive ? 1 : 0,
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt.toIso8601String(),
      journalEntryId: entity.journalEntryId?.value,
    );
  }

  /// تحويل النموذج إلى كيان المجال
  FixedAsset toEntity() {
    return FixedAsset(
      id: UniqueId.fromUniqueString(id),
      code: code,
      name: name,
      categoryId: UniqueId.fromUniqueString(categoryId),
      categoryName: categoryName,
      purchaseDate: DateTime.parse(purchaseDate),
      purchaseCost: Money.fromDouble(purchaseCost, _parseCurrency(currencyCode)),
      currency: _parseCurrency(currencyCode),
      fxRate: MoneyFxRate(
        fromCurrency: _parseCurrency(currencyCode),
        toCurrency: Currency.syp(),
        rate: fxRate,
        rateDate: DateTime.parse(fxRateDate),
      ),
      usefulLifeMonths: usefulLifeMonths,
      salvageValue: salvageValue != null
          ? Money.fromDouble(salvageValue!, _parseCurrency(currencyCode))
          : null,
      accumulatedDepreciation: Money.fromDouble(
        accumulatedDepreciation,
        _parseCurrency(currencyCode),
      ),
      netBookValue: Money.fromDouble(
        netBookValue,
        _parseCurrency(currencyCode),
      ),
      status: _parseStatus(status),
      location: location,
      notes: notes,
      isActive: isActive == 1,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
      journalEntryId: journalEntryId != null
          ? UniqueId.fromUniqueString(journalEntryId!)
          : null,
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

  AssetStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AssetStatus.active;
      case 'inactive':
        return AssetStatus.inactive;
      case 'disposed':
        return AssetStatus.disposed;
      case 'sold':
        return AssetStatus.sold;
      case 'damaged':
        return AssetStatus.damaged;
      default:
        return AssetStatus.active;
    }
  }
}
