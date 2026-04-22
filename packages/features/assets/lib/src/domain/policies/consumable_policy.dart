import 'package:dartz/dartz.dart';
import 'package:foundation/foundation.dart';
import '../entities/asset_entities.dart';
import '../failures/asset_failures.dart';

/// سياسات أعمال المستهلكات
class ConsumablePolicy {
  /// الحد الأدنى للكمية قبل التحذير (يمكن تخصيصه لكل صنف)
  static const double defaultMinStockLevel = 10.0;
  
  /// التحقق من صلاحية إنشاء مستهلك جديد
  static Either<AssetFailure, Unit> validateCreation(ConsumableItem item) {
    // التحقق من الاسم
    if (item.name.trim().isEmpty) {
      return Left(InvalidConsumableFailure.invalidName());
    }
    
    // التحقق من الكود
    if (item.code.trim().isEmpty) {
      return Left(InvalidConsumableFailure.invalidCode());
    }
    
    // التحقق من التصنيف
    if (item.categoryId.value.isEmpty) {
      return Left(const InvalidConsumableFailure('تصنيف المستهلك غير صالح'));
    }
    
    // التحقق من الكمية
    if (item.quantityOnHand.value < 0) {
      return Left(NegativeQuantityFailure(item.quantityOnHand));
    }
    
    // التحقق من تكلفة الوحدة
    if (item.unitCost.amount < 0) {
      return Left(InvalidConsumableFailure.invalidUnitCost());
    }
    
    // التحقق من سعر الصرف للعملات الأجنبية
    if (item.currency.code != 'SYP' && item.fxRate.rate <= 0) {
      return Left(MissingExchangeRateFailure(
        fromCurrency: item.currency,
        toCurrency: Currency.syp(),
      ));
    }
    
    return const Right(unit);
  }
  
  /// التحقق من صلاحية صرف كمية
  static Either<AssetFailure, Unit> validateIssue(
    ConsumableItem item,
    Quantity quantity,
  ) {
    // التحقق من أن الكمية المطلوبة موجبة
    if (quantity.value <= 0) {
      return Left(const InvalidConsumableFailure('الكمية المصروفة يجب أن تكون أكبر من صفر'));
    }
    
    // التحقق من توفر الكمية
    if (!item.hasSufficientStock(quantity)) {
      return Left(InsufficientConsumableStockFailure(
        required: quantity,
        available: item.quantityOnHand,
      ));
    }
    
    // التحقق من حالة المستهلك
    if (item.status == ConsumableStatus.exhausted) {
      return Left(const InvalidConsumableFailure('المستهلك منتهي ولا يمكن صرفه'));
    }
    
    return const Right(unit);
  }
  
  /// التحقق من صلاحية الاستهلاك
  static Either<AssetFailure, Unit> validateConsumption(
    ConsumableItem item,
    Quantity quantity,
    String? department,
  ) {
    // استخدام نفس التحققات الخاصة بالصرف
    final issueResult = validateIssue(item, quantity);
    if (issueResult.isLeft()) {
      return issueResult;
    }
    
    // التحقق من تحديد الجهة المستفيدة
    if (department == null || department.trim().isEmpty) {
      // هذا تحذير فقط، يمكن السماح به في بعض الحالات
      // return Left(const InvalidConsumableFailure('يجب تحديد الجهة المستفيدة'));
    }
    
    return const Right(unit);
  }
  
  /// التحقق من صلاحية استلام كمية
  static Either<AssetFailure, Unit> validateReceipt(
    ConsumableItem item,
    Quantity quantity,
    Money unitCost,
  ) {
    // التحقق من أن الكمية المستلمة موجبة
    if (quantity.value <= 0) {
      return Left(const InvalidConsumableFailure('الكمية المستلمة يجب أن تكون أكبر من صفر'));
    }
    
    // التحقق من تكلفة الوحدة
    if (unitCost.amount < 0) {
      return Left(InvalidConsumableFailure.invalidUnitCost());
    }
    
    return const Right(unit);
  }
  
  /// التحقق من صلاحية تسوية المخزون
  static Either<AssetFailure, Unit> validateAdjustment(
    ConsumableItem item,
    Quantity newQuantity,
    String reason,
  ) {
    // التحقق من الكمية الجديدة
    if (newQuantity.value < 0) {
      return Left(NegativeQuantityFailure(newQuantity));
    }
    
    // التحقق من وجود سبب للتسوية
    if (reason.trim().isEmpty) {
      return Left(const InvalidConsumableFailure('يجب تحديد سبب التسوية'));
    }
    
    return const Right(unit);
  }
  
  /// التحقق من توفر المخزون
  static Either<AssetFailure, Unit> validateStockAvailability(
    ConsumableItem item,
    Quantity requiredQuantity,
  ) {
    if (!item.hasSufficientStock(requiredQuantity)) {
      return Left(InsufficientConsumableStockFailure(
        required: requiredQuantity,
        available: item.quantityOnHand,
      ));
    }
    
    return const Right(unit);
  }
  
  /// تحديد حالة المخزون (منخفض/متوفر)
  static ConsumableStatus determineStockStatus(
    ConsumableItem item, {
    double? minStockLevel,
  }) {
    final minLevel = minStockLevel ?? defaultMinStockLevel;
    
    if (item.quantityOnHand.value <= 0) {
      return ConsumableStatus.exhausted;
    }
    
    if (item.quantityOnHand.value < minLevel) {
      return ConsumableStatus.lowStock;
    }
    
    return ConsumableStatus.inStock;
  }
  
  /// التحقق من قواعد الصرف حسب الجهة
  static Either<AssetFailure, Unit> validateIssueRules(
    ConsumableItem item,
    Quantity quantity,
    String department,
    String? authorizedBy,
  ) {
    // التحقق الأساسي
    final basicValidation = validateIssue(item, quantity);
    if (basicValidation.isLeft()) {
      return basicValidation;
    }
    
    // التحقق من الصلاحيات (يمكن توسيعه لاحقاً)
    if (authorizedBy == null || authorizedBy.trim().isEmpty) {
      // يمكن أن يكون هذا تحذيراً أو خطأ حسب السياسة
      // return Left(const InvalidConsumableFailure('يجب تحديد المفوض بالصرف'));
    }
    
    return const Right(unit);
  }
  
  /// حساب تكلفة الاستهلاك
  static Money calculateConsumptionCost(
    ConsumableItem item,
    Quantity quantity,
  ) {
    return item.unitCost.multiply(quantity.value);
  }
  
  /// حساب قيمة المخزون
  static Money calculateInventoryValue(ConsumableItem item) {
    return item.unitCost.multiply(item.quantityOnHand.value);
  }
}
