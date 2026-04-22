import 'package:equatable/equatable.dart';
import 'package:foundation/foundation.dart';

/// تمثل المادة المستهلكة أو المستلزمات التشغيلية
/// مثل: مواد التعبئة، مستلزمات المطبخ، الورق، الأكياس
class ConsumableItem extends Equatable {
  final UniqueId id;
  final String code;
  final String name;
  final UniqueId categoryId;
  final String? categoryName;
  final Quantity quantityOnHand;
  final Quantity unitOfMeasure;
  final Money unitCost;
  final Currency currency;
  final MoneyFxRate fxRate;
  final Money totalCost;
  final ConsumableStatus status;
  final String? location;
  final String? notes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UniqueId? journalEntryId;

  const ConsumableItem({
    required this.id,
    required this.code,
    required this.name,
    required this.categoryId,
    this.categoryName,
    required this.quantityOnHand,
    required this.unitOfMeasure,
    required this.unitCost,
    required this.currency,
    required this.fxRate,
    required this.totalCost,
    required this.status,
    this.location,
    this.notes,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.journalEntryId,
  });

  ConsumableItem copyWith({
    String? name,
    UniqueId? categoryId,
    String? categoryName,
    Quantity? quantityOnHand,
    Quantity? unitOfMeasure,
    Money? unitCost,
    Currency? currency,
    MoneyFxRate? fxRate,
    Money? totalCost,
    ConsumableStatus? status,
    String? location,
    String? notes,
    bool? isActive,
    DateTime? updatedAt,
    UniqueId? journalEntryId,
  }) {
    return ConsumableItem(
      id: id,
      code: code,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      quantityOnHand: quantityOnHand ?? this.quantityOnHand,
      unitOfMeasure: unitOfMeasure ?? this.unitOfMeasure,
      unitCost: unitCost ?? this.unitCost,
      currency: currency ?? this.currency,
      fxRate: fxRate ?? this.fxRate,
      totalCost: totalCost ?? this.totalCost,
      status: status ?? this.status,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      journalEntryId: journalEntryId ?? this.journalEntryId,
    );
  }

  /// حساب التكلفة الإجمالية بناءً على الكمية
  Money calculateTotalCost(Quantity quantity) {
    return unitCost.multiply(quantity.value);
  }

  /// التحقق من توفر الكمية
  bool hasSufficientStock(Quantity requiredQuantity) {
    return quantityOnHand.value >= requiredQuantity.value;
  }

  /// صرف كمية من المخزون
  ConsumableItem issue(Quantity quantity) {
    if (!hasSufficientStock(quantity)) {
      throw InsufficientConsumableStockFailure(
        required: quantity,
        available: quantityOnHand,
      );
    }

    final newQuantity = quantityOnHand.subtract(quantity);
    final newTotalCost = unitCost.multiply(newQuantity.value);

    return copyWith(
      quantityOnHand: newQuantity,
      totalCost: newTotalCost,
      updatedAt: DateTime.now(),
    );
  }

  /// استلام كمية جديدة
  ConsumableItem receive(Quantity quantity, Money newUnitCost) {
    final newQuantity = quantityOnHand.add(quantity);
    
    // حساب متوسط التكلفة
    final totalExistingCost = unitCost.multiply(quantityOnHand.value);
    final totalNewCost = newUnitCost.multiply(quantity.value);
    final combinedTotalCost = totalExistingCost.add(totalNewCost);
    
    final averageUnitCost = newQuantity.value > 0
        ? combinedTotalCost.divide(newQuantity.value)
        : newUnitCost;

    return copyWith(
      quantityOnHand: newQuantity,
      unitCost: averageUnitCost,
      totalCost: combinedTotalCost,
      updatedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        code,
        name,
        categoryId,
        quantityOnHand,
        unitCost,
        currency,
        fxRate,
        totalCost,
        status,
        isActive,
      ];
}

/// حالة المادة المستهلكة
enum ConsumableStatus {
  inStock,
  lowStock,
  consumed,
  exhausted,
  damaged,
}

extension ConsumableStatusExtension on ConsumableStatus {
  String get displayName {
    switch (this) {
      case ConsumableStatus.inStock:
        return 'متوفر';
      case ConsumableStatus.lowStock:
        return 'منخفض';
      case ConsumableStatus.consumed:
        return 'مستهلك';
      case ConsumableStatus.exhausted:
        return 'منتهي';
      case ConsumableStatus.damaged:
        return 'تالف';
    }
  }

  String get englishName {
    switch (this) {
      case ConsumableStatus.inStock:
        return 'in_stock';
      case ConsumableStatus.lowStock:
        return 'low_stock';
      case ConsumableStatus.consumed:
        return 'consumed';
      case ConsumableStatus.exhausted:
        return 'exhausted';
      case ConsumableStatus.damaged:
        return 'damaged';
    }
  }
}

/// خطأ: كمية غير كافية من المستهلكات
class InsufficientConsumableStockFailure implements Exception {
  final Quantity required;
  final Quantity available;

  const InsufficientConsumableStockFailure({
    required this.required,
    required this.available,
  });

  @override
  String toString() =>
      'كمية غير كافية: المطلوب ${required.value}, المتاح ${available.value}';
}
