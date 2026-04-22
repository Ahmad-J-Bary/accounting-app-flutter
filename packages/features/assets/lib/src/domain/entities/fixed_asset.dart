import 'package:equatable/equatable.dart';
import 'package:foundation/foundation.dart';

/// تمثل الأصل الثابت في النظام المحاسبي
/// مثل: المعدات، الأدوات، الأجهزة، المركبات
class FixedAsset extends Equatable {
  final UniqueId id;
  final String code;
  final String name;
  final UniqueId categoryId;
  final String? categoryName;
  final DateTime purchaseDate;
  final Money purchaseCost;
  final Currency currency;
  final MoneyFxRate fxRate;
  final int usefulLifeMonths;
  final Money? salvageValue;
  final Money accumulatedDepreciation;
  final Money netBookValue;
  final AssetStatus status;
  final String? location;
  final String? notes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UniqueId? journalEntryId;

  const FixedAsset({
    required this.id,
    required this.code,
    required this.name,
    required this.categoryId,
    this.categoryName,
    required this.purchaseDate,
    required this.purchaseCost,
    required this.currency,
    required this.fxRate,
    required this.usefulLifeMonths,
    this.salvageValue,
    required this.accumulatedDepreciation,
    required this.netBookValue,
    required this.status,
    this.location,
    this.notes,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.journalEntryId,
  });

  FixedAsset copyWith({
    String? name,
    UniqueId? categoryId,
    String? categoryName,
    DateTime? purchaseDate,
    Money? purchaseCost,
    Currency? currency,
    MoneyFxRate? fxRate,
    int? usefulLifeMonths,
    Money? salvageValue,
    Money? accumulatedDepreciation,
    Money? netBookValue,
    AssetStatus? status,
    String? location,
    String? notes,
    bool? isActive,
    DateTime? updatedAt,
    UniqueId? journalEntryId,
  }) {
    return FixedAsset(
      id: id,
      code: code,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      purchaseCost: purchaseCost ?? this.purchaseCost,
      currency: currency ?? this.currency,
      fxRate: fxRate ?? this.fxRate,
      usefulLifeMonths: usefulLifeMonths ?? this.usefulLifeMonths,
      salvageValue: salvageValue ?? this.salvageValue,
      accumulatedDepreciation: accumulatedDepreciation ?? this.accumulatedDepreciation,
      netBookValue: netBookValue ?? this.netBookValue,
      status: status ?? this.status,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      journalEntryId: journalEntryId ?? this.journalEntryId,
    );
  }

  /// حساب قيمة الاهلاك الشهرية
  Money get monthlyDepreciation {
    final salvage = salvageValue ?? Money.zero(currency);
    final depreciableAmount = purchaseCost.subtract(salvage);
    final monthlyAmount = depreciableAmount.amount / usefulLifeMonths;
    return Money.fromDecimal(
      Decimal.parse(monthlyAmount.toString()),
      currency,
    );
  }

  /// التحقق إذا كان الأصل قابلاً للاهلاك
  bool get isDepreciable =>
      status == AssetStatus.active &&
      usefulLifeMonths > 0 &&
      netBookValue.amount > 0;

  @override
  List<Object?> get props => [
        id,
        code,
        name,
        categoryId,
        purchaseDate,
        purchaseCost,
        currency,
        fxRate,
        usefulLifeMonths,
        salvageValue,
        accumulatedDepreciation,
        netBookValue,
        status,
        isActive,
      ];
}

/// حالة الأصل الثابت
enum AssetStatus {
  active,
  inactive,
  disposed,
  sold,
  damaged,
}

/// طرق حساب الاهلاك
enum DepreciationMethod {
  straightLine,
  decliningBalance,
  unitsOfProduction,
}

extension AssetStatusExtension on AssetStatus {
  String get displayName {
    switch (this) {
      case AssetStatus.active:
        return 'نشط';
      case AssetStatus.inactive:
        return 'غير نشط';
      case AssetStatus.disposed:
        return 'مستبعد';
      case AssetStatus.sold:
        return 'مباع';
      case AssetStatus.damaged:
        return 'تالف';
    }
  }

  String get englishName {
    switch (this) {
      case AssetStatus.active:
        return 'active';
      case AssetStatus.inactive:
        return 'inactive';
      case AssetStatus.disposed:
        return 'disposed';
      case AssetStatus.sold:
        return 'sold';
      case AssetStatus.damaged:
        return 'damaged';
    }
  }
}
