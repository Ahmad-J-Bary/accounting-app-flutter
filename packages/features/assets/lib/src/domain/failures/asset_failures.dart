import 'package:foundation/foundation.dart';

/// أخطاء عامة في وحدة الأصول
abstract class AssetFailure extends Failure {
  const AssetFailure(String message) : super(message);
}

/// خطأ: أصل غير صالح
class InvalidAssetFailure extends AssetFailure {
  const InvalidAssetFailure(String message) : super(message);
  
  factory InvalidAssetFailure.invalidCode() =>
      const InvalidAssetFailure('كود الأصل غير صالح');
  
  factory InvalidAssetFailure.invalidName() =>
      const InvalidAssetFailure('اسم الأصل غير صالح');
  
  factory InvalidAssetFailure.invalidCategory() =>
      const InvalidAssetFailure('تصنيف الأصل غير صالح');
}

/// خطأ: مستهلك غير صالح
class InvalidConsumableFailure extends AssetFailure {
  const InvalidConsumableFailure(String message) : super(message);
  
  factory InvalidConsumableFailure.invalidCode() =>
      const InvalidConsumableFailure('كود المستهلك غير صالح');
  
  factory InvalidConsumableFailure.invalidName() =>
      const InvalidConsumableFailure('اسم المستهلك غير صالح');
  
  factory InvalidConsumableFailure.invalidQuantity() =>
      const InvalidConsumableFailure('الكمية غير صالحة');
  
  factory InvalidConsumableFailure.invalidUnitCost() =>
      const InvalidConsumableFailure('تكلفة الوحدة غير صالحة');
}

/// خطأ: كمية سالبة
class NegativeQuantityFailure extends AssetFailure {
  final Quantity quantity;
  
  const NegativeQuantityFailure(this.quantity)
      : super('الكمية ${quantity.value} لا يمكن أن تكون سالبة');
}

/// خطأ: اهلاك غير صالح
class InvalidDepreciationFailure extends AssetFailure {
  const InvalidDepreciationFailure(String message) : super(message);
  
  factory InvalidDepreciationFailure.invalidLife() =>
      const InvalidDepreciationFailure('العمر الإنتاجي غير صالح');
  
  factory InvalidDepreciationFailure.invalidMethod() =>
      const InvalidDepreciationFailure('طريقة الاهلاك غير صالحة');
  
  factory InvalidDepreciationFailure.negativeAmount() =>
      const InvalidDepreciationFailure('مبلغ الاهلاك لا يمكن أن يكون سالباً');
}

/// خطأ: الأصل مستبعد بالفعل
class AssetAlreadyDisposedFailure extends AssetFailure {
  final UniqueId assetId;
  
  const AssetAlreadyDisposedFailure(this.assetId)
      : super('الأصل ${assetId.value} مستبعد بالفعل');
}

/// خطأ: كمية غير كافية من المستهلكات
class InsufficientConsumableStockFailure extends AssetFailure {
  final Quantity required;
  final Quantity available;
  
  const InsufficientConsumableStockFailure({
    required this.required,
    required this.available,
  }) : super('الكمية المطلوبة ${required.value} أكبر من المتاح ${available.value}');
}

/// خطأ: سعر الصرف مفقود
class MissingExchangeRateFailure extends AssetFailure {
  final Currency fromCurrency;
  final Currency toCurrency;
  
  const MissingExchangeRateFailure({
    required this.fromCurrency,
    required this.toCurrency,
  }) : super('سعر الصرف من ${fromCurrency.code} إلى ${toCurrency.code} غير متوفر');
}

/// خطأ: قيد محاسبي غير متوازن
class UnbalancedAssetEntryFailure extends AssetFailure {
  final Money totalDebits;
  final Money totalCredits;
  
  const UnbalancedAssetEntryFailure({
    required this.totalDebits,
    required this.totalCredits,
  }) : super('القيد غير متوازن: مدين ${totalDebits.amount} / دائن ${totalCredits.amount}');
}

/// خطأ: حركة غير مسموح بها
class InvalidAssetMovementFailure extends AssetFailure {
  const InvalidAssetMovementFailure(String message) : super(message);
  
  factory InvalidAssetMovementFailure.invalidType() =>
      const InvalidAssetMovementFailure('نوع الحركة غير صالح');
  
  factory InvalidAssetMovementFailure.invalidDate() =>
      const InvalidAssetMovementFailure('تاريخ الحركة غير صالح');
  
  factory InvalidAssetMovementFailure.invalidAmount() =>
      const InvalidAssetMovementFailure('مبلغ الحركة غير صالح');
}

/// خطأ: الأصل غير موجود
class AssetNotFoundFailure extends AssetFailure {
  final UniqueId assetId;
  
  const AssetNotFoundFailure(this.assetId)
      : super('الأصل ${assetId.value} غير موجود');
}

/// خطأ: المستهلك غير موجود
class ConsumableNotFoundFailure extends AssetFailure {
  final UniqueId consumableId;
  
  const ConsumableNotFoundFailure(this.consumableId)
      : super('المستهلك ${consumableId.value} غير موجود');
}

/// خطأ: التصنيف غير موجود
class CategoryNotFoundFailure extends AssetFailure {
  final UniqueId categoryId;
  
  const CategoryNotFoundFailure(this.categoryId)
      : super('التصنيف ${categoryId.value} غير موجود');
}

/// خطأ: الأصل محمي ضد التعديل
class AssetLockedFailure extends AssetFailure {
  final UniqueId assetId;
  final String reason;
  
  const AssetLockedFailure({
    required this.assetId,
    required this.reason,
  }) : super('الأصل ${assetId.value} محمي: $reason');
}

/// خطأ: تاريخ غير صالح
class InvalidDateFailure extends AssetFailure {
  final DateTime? date;
  final String reason;
  
  const InvalidDateFailure({
    this.date,
    required this.reason,
  }) : super('تاريخ غير صالح: $reason');
}

/// خطأ: عملة غير صالحة
class InvalidCurrencyFailure extends AssetFailure {
  final String currencyCode;
  
  const InvalidCurrencyFailure(this.currencyCode)
      : super('العملة $currencyCode غير صالحة أو غير مدعومة');
}
