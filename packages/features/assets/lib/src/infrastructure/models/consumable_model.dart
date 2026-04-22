import 'package:foundation/foundation.dart';
import '../../../domain/domain.dart';

/// نموذج المستهلك للتخزين في قاعدة البيانات
class ConsumableModel {
  final String id;
  final String code;
  final String name;
  final String categoryId;
  final String? categoryName;
  final double quantityOnHand;
  final String unitOfMeasure;
  final double unitCost;
  final String currencyCode;
  final double fxRate;
  final String fxRateDate;
  final double totalCost;
  final String status; // ConsumableStatus enum as string
  final String? location;
  final String? notes;
  final int isActive; // 1 = true, 0 = false
  final String createdAt;
  final String updatedAt;
  final String? journalEntryId;
  final double? minStockLevel; // الحد الأدنى للتنبيه

  const ConsumableModel({
    required this.id,
    required this.code,
    required this.name,
    required this.categoryId,
    this.categoryName,
    required this.quantityOnHand,
    required this.unitOfMeasure,
    required this.unitCost,
    required this.currencyCode,
    required this.fxRate,
    required this.fxRateDate,
    required this.totalCost,
    required this.status,
    this.location,
    this.notes,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.journalEntryId,
    this.minStockLevel,
  });

  factory ConsumableModel.fromJson(Map<String, dynamic> json) {
    return ConsumableModel(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      categoryId: json['categoryId'] as String,
      categoryName: json['categoryName'] as String?,
      quantityOnHand: (json['quantityOnHand'] as num).toDouble(),
      unitOfMeasure: json['unitOfMeasure'] as String,
      unitCost: (json['unitCost'] as num).toDouble(),
      currencyCode: json['currencyCode'] as String,
      fxRate: (json['fxRate'] as num).toDouble(),
      fxRateDate: json['fxRateDate'] as String,
      totalCost: (json['totalCost'] as num).toDouble(),
      status: json['status'] as String,
      location: json['location'] as String?,
      notes: json['notes'] as String?,
      isActive: json['isActive'] as int,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      journalEntryId: json['journalEntryId'] as String?,
      minStockLevel: json['minStockLevel'] != null
          ? (json['minStockLevel'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'quantityOnHand': quantityOnHand,
      'unitOfMeasure': unitOfMeasure,
      'unitCost': unitCost,
      'currencyCode': currencyCode,
      'fxRate': fxRate,
      'fxRateDate': fxRateDate,
      'totalCost': totalCost,
      'status': status,
      'location': location,
      'notes': notes,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'journalEntryId': journalEntryId,
      'minStockLevel': minStockLevel,
    };
  }

  /// تحويل من كيان المجال إلى نموذج
  factory ConsumableModel.fromEntity(ConsumableItem entity) {
    return ConsumableModel(
      id: entity.id.value,
      code: entity.code,
      name: entity.name,
      categoryId: entity.categoryId.value,
      categoryName: entity.categoryName,
      quantityOnHand: entity.quantityOnHand.value,
      unitOfMeasure: entity.unitOfMeasure.unit,
      unitCost: entity.unitCost.amount.toDouble(),
      currencyCode: entity.currency.code,
      fxRate: entity.fxRate.rate,
      fxRateDate: entity.fxRate.rateDate.toIso8601String(),
      totalCost: entity.totalCost.amount.toDouble(),
      status: entity.status.englishName,
      location: entity.location,
      notes: entity.notes,
      isActive: entity.isActive ? 1 : 0,
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt.toIso8601String(),
      journalEntryId: entity.journalEntryId?.value,
      minStockLevel: null, // يمكن تخصيصه لاحقاً
    );
  }

  /// تحويل النموذج إلى كيان المجال
  ConsumableItem toEntity() {
    return ConsumableItem(
      id: UniqueId.fromUniqueString(id),
      code: code,
      name: name,
      categoryId: UniqueId.fromUniqueString(categoryId),
      categoryName: categoryName,
      quantityOnHand: Quantity(quantityOnHand, unitOfMeasure),
      unitOfMeasure: Quantity(1, unitOfMeasure), // الوحدة الأساسية
      unitCost: Money.fromDouble(unitCost, _parseCurrency(currencyCode)),
      currency: _parseCurrency(currencyCode),
      fxRate: MoneyFxRate(
        fromCurrency: _parseCurrency(currencyCode),
        toCurrency: Currency.syp(),
        rate: fxRate,
        rateDate: DateTime.parse(fxRateDate),
      ),
      totalCost: Money.fromDouble(totalCost, _parseCurrency(currencyCode)),
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

  ConsumableStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'in_stock':
        return ConsumableStatus.inStock;
      case 'low_stock':
        return ConsumableStatus.lowStock;
      case 'consumed':
        return ConsumableStatus.consumed;
      case 'exhausted':
        return ConsumableStatus.exhausted;
      case 'damaged':
        return ConsumableStatus.damaged;
      default:
        return ConsumableStatus.inStock;
    }
  }
}
