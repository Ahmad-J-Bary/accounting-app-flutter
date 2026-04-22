import 'package:dartz/dartz.dart';
import 'package:foundation/foundation.dart';
import '../entities/asset_entities.dart';
import '../failures/asset_failures.dart';

/// سياسات أعمال الأصول الثابتة
class FixedAssetPolicy {
  /// التحقق من صلاحية إنشاء أصل جديد
  static Either<AssetFailure, Unit> validateAcquisition(FixedAsset asset) {
    // التحقق من الاسم
    if (asset.name.trim().isEmpty) {
      return Left(InvalidAssetFailure.invalidName());
    }
    
    // التحقق من الكود
    if (asset.code.trim().isEmpty) {
      return Left(InvalidAssetFailure.invalidCode());
    }
    
    // التحقق من التصنيف
    if (asset.categoryId.value.isEmpty) {
      return Left(InvalidAssetFailure.invalidCategory());
    }
    
    // التحقق من التكلفة
    if (asset.purchaseCost.amount <= 0) {
      return Left(const InvalidAssetFailure('تكلفة الشراء يجب أن تكون أكبر من صفر'));
    }
    
    // التحقق من العمر الإنتاجي
    if (asset.usefulLifeMonths < 0) {
      return Left(InvalidDepreciationFailure.invalidLife());
    }
    
    // التحقق من القيمة المتبقية
    final salvage = asset.salvageValue;
    if (salvage != null && salvage.amount >= asset.purchaseCost.amount) {
      return Left(const InvalidAssetFailure('القيمة المتبقية يجب أن تكون أقل من تكلفة الشراء'));
    }
    
    // التحقق من سعر الصرف للعملات الأجنبية
    if (asset.currency.code != 'SYP' && asset.fxRate.rate <= 0) {
      return Left(MissingExchangeRateFailure(
        fromCurrency: asset.currency,
        toCurrency: Currency.syp(),
      ));
    }
    
    return const Right(unit);
  }
  
  /// التحقق من صلاحية تسجيل الاهلاك
  static Either<AssetFailure, Unit> validateDepreciation(
    FixedAsset asset,
    Money depreciationAmount,
  ) {
    // لا يمكن اهلاك أصل غير نشط
    if (asset.status != AssetStatus.active) {
      return Left(const InvalidDepreciationFailure('لا يمكن اهلاك أصل غير نشط'));
    }
    
    // لا يمكن اهلاك أصل مستبعد
    if (asset.status == AssetStatus.disposed ||
        asset.status == AssetStatus.sold) {
      return Left(AssetAlreadyDisposedFailure(asset.id));
    }
    
    // التحقق من مبلغ الاهلاك
    if (depreciationAmount.amount <= 0) {
      return Left(InvalidDepreciationFailure.negativeAmount());
    }
    
    // التحقق من عدم تجاوز القيمة الدفترية
    if (depreciationAmount.amount > asset.netBookValue.amount) {
      return Left(const InvalidDepreciationFailure('مبلغ الاهلاك أكبر من القيمة الدفترية'));
    }
    
    return const Right(unit);
  }
  
  /// التحقق من صلاحية استبعاد أصل
  static Either<AssetFailure, Unit> validateDisposal(FixedAsset asset) {
    // لا يمكن استبعاد أصل مستبعد بالفعل
    if (asset.status == AssetStatus.disposed) {
      return Left(AssetAlreadyDisposedFailure(asset.id));
    }
    
    return const Right(unit);
  }
  
  /// التحقق من صلاحية بيع أصل
  static Either<AssetFailure, Unit> validateSale(
    FixedAsset asset,
    Money salePrice,
  ) {
    // لا يمكن بيع أصل مستبعد
    if (asset.status == AssetStatus.disposed ||
        asset.status == AssetStatus.sold) {
      return Left(AssetAlreadyDisposedFailure(asset.id));
    }
    
    // التحقق من سعر البيع
    if (salePrice.amount < 0) {
      return Left(const InvalidAssetFailure('سعر البيع لا يمكن أن يكون سالباً'));
    }
    
    return const Right(unit);
  }
  
  /// التحقق من صلاحية إعادة التقييم
  static Either<AssetFailure, Unit> validateRevaluation(
    FixedAsset asset,
    Money newValue,
  ) {
    // لا يمكن إعادة تقييم أصل مستبعد
    if (asset.status == AssetStatus.disposed ||
        asset.status == AssetStatus.sold) {
      return Left(AssetAlreadyDisposedFailure(asset.id));
    }
    
    // التحقق من القيمة الجديدة
    if (newValue.amount < 0) {
      return Left(const InvalidAssetFailure('القيمة الجديدة لا يمكن أن تكون سالبة'));
    }
    
    return const Right(unit);
  }
  
  /// حساب الربح أو الخسارة عند البيع
  static Money calculateGainOrLoss(FixedAsset asset, Money salePrice) {
    return salePrice.subtract(asset.netBookValue);
  }
  
  /// التحقق من القيمة الدفترية الصافية
  static Either<AssetFailure, Unit> validateNetBookValue(FixedAsset asset) {
    if (asset.netBookValue.amount < 0) {
      return Left(const InvalidAssetFailure('القيمة الدفترية الصافية لا يمكن أن تكون سالبة'));
    }
    
    return const Right(unit);
  }
}
