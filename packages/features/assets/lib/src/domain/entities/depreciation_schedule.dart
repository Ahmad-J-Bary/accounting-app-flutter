import 'package:equatable/equatable.dart';
import 'package:foundation/foundation.dart';

/// جدول الاهلاك للأصل الثابت
class DepreciationSchedule extends Equatable {
  final UniqueId id;
  final UniqueId fixedAssetId;
  final String fixedAssetName;
  final DateTime startDate;
  final int usefulLifeMonths;
  final DepreciationMethod method;
  final Money monthlyDepreciation;
  final Money accumulatedDepreciation;
  final Money remainingValue;
  final int remainingMonths;
  final bool isComplete;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DepreciationSchedule({
    required this.id,
    required this.fixedAssetId,
    required this.fixedAssetName,
    required this.startDate,
    required this.usefulLifeMonths,
    required this.method,
    required this.monthlyDepreciation,
    required this.accumulatedDepreciation,
    required this.remainingValue,
    required this.remainingMonths,
    this.isComplete = false,
    required this.createdAt,
    required this.updatedAt,
  });

  DepreciationSchedule copyWith({
    Money? monthlyDepreciation,
    Money? accumulatedDepreciation,
    Money? remainingValue,
    int? remainingMonths,
    bool? isComplete,
    DateTime? updatedAt,
  }) {
    return DepreciationSchedule(
      id: id,
      fixedAssetId: fixedAssetId,
      fixedAssetName: fixedAssetName,
      startDate: startDate,
      usefulLifeMonths: usefulLifeMonths,
      method: method,
      monthlyDepreciation: monthlyDepreciation ?? this.monthlyDepreciation,
      accumulatedDepreciation: accumulatedDepreciation ?? this.accumulatedDepreciation,
      remainingValue: remainingValue ?? this.remainingValue,
      remainingMonths: remainingMonths ?? this.remainingMonths,
      isComplete: isComplete ?? this.isComplete,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// تسجيل شهر اهلاك
  DepreciationSchedule recordMonth() {
    if (isComplete || remainingMonths <= 0) {
      return this;
    }

    final newAccumulatedDepreciation = accumulatedDepreciation.add(monthlyDepreciation);
    final newRemainingValue = remainingValue.subtract(monthlyDepreciation);
    final newRemainingMonths = remainingMonths - 1;
    final newIsComplete = newRemainingMonths <= 0 || newRemainingValue.amount <= 0;

    return copyWith(
      accumulatedDepreciation: newAccumulatedDepreciation,
      remainingValue: newRemainingValue,
      remainingMonths: newRemainingMonths,
      isComplete: newIsComplete,
      updatedAt: DateTime.now(),
    );
  }

  /// حساب الاهلاك المتراكم حتى تاريخ معين
  Money calculateDepreciationToDate(DateTime targetDate) {
    if (targetDate.isBefore(startDate)) {
      return Money.zero(accumulatedDepreciation.currency);
    }

    final monthsElapsed = _calculateMonthsBetween(startDate, targetDate);
    final effectiveMonths = monthsElapsed > usefulLifeMonths ? usefulLifeMonths : monthsElapsed;
    
    return monthlyDepreciation.multiply(effectiveMonths.toDouble());
  }

  int _calculateMonthsBetween(DateTime start, DateTime end) {
    return (end.year - start.year) * 12 + end.month - start.month;
  }

  @override
  List<Object?> get props => [
        id,
        fixedAssetId,
        startDate,
        usefulLifeMonths,
        method,
        accumulatedDepreciation,
        remainingValue,
        remainingMonths,
        isComplete,
      ];
}

/// خط الاهلاك الشهري
class DepreciationEntry extends Equatable {
  final UniqueId id;
  final UniqueId scheduleId;
  final UniqueId fixedAssetId;
  final DateTime periodDate;
  final int periodNumber;
  final Money depreciationAmount;
  final Money accumulatedDepreciation;
  final Money remainingValue;
  final bool isPosted;
  final UniqueId? journalEntryId;
  final DateTime createdAt;

  const DepreciationEntry({
    required this.id,
    required this.scheduleId,
    required this.fixedAssetId,
    required this.periodDate,
    required this.periodNumber,
    required this.depreciationAmount,
    required this.accumulatedDepreciation,
    required this.remainingValue,
    this.isPosted = false,
    this.journalEntryId,
    required this.createdAt,
  });

  DepreciationEntry copyWith({
    bool? isPosted,
    UniqueId? journalEntryId,
  }) {
    return DepreciationEntry(
      id: id,
      scheduleId: scheduleId,
      fixedAssetId: fixedAssetId,
      periodDate: periodDate,
      periodNumber: periodNumber,
      depreciationAmount: depreciationAmount,
      accumulatedDepreciation: accumulatedDepreciation,
      remainingValue: remainingValue,
      isPosted: isPosted ?? this.isPosted,
      journalEntryId: journalEntryId ?? this.journalEntryId,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        scheduleId,
        fixedAssetId,
        periodDate,
        periodNumber,
        depreciationAmount,
        isPosted,
      ];
}

/// طرق حساب الاهلاك
enum DepreciationMethod {
  straightLine,      // القسط الثابت
  decliningBalance,  // المتناقص
  sumOfYears,       // مجموع سنوات العمر
  unitsOfProduction, // وحدات الإنتاج
}

extension DepreciationMethodExtension on DepreciationMethod {
  String get displayName {
    switch (this) {
      case DepreciationMethod.straightLine:
        return 'القسط الثابت';
      case DepreciationMethod.decliningBalance:
        return 'المتناقص';
      case DepreciationMethod.sumOfYears:
        return 'مجموع سنوات العمر';
      case DepreciationMethod.unitsOfProduction:
        return 'وحدات الإنتاج';
    }
  }

  String get englishName {
    switch (this) {
      case DepreciationMethod.straightLine:
        return 'straight_line';
      case DepreciationMethod.decliningBalance:
        return 'declining_balance';
      case DepreciationMethod.sumOfYears:
        return 'sum_of_years';
      case DepreciationMethod.unitsOfProduction:
        return 'units_of_production';
    }
  }
}

/// الآلة الحاسبة للاهلاك
class DepreciationCalculator {
  /// حساب الاهلاك بطريقة القسط الثابت
  static Money calculateStraightLine(
    Money cost,
    Money? salvageValue,
    int usefulLifeMonths,
  ) {
    final salvage = salvageValue ?? Money.zero(cost.currency);
    final depreciableAmount = cost.subtract(salvage);
    
    if (usefulLifeMonths <= 0) {
      return Money.zero(cost.currency);
    }
    
    final monthlyAmount = depreciableAmount.amount / usefulLifeMonths;
    return Money.fromDecimal(
      Decimal.parse(monthlyAmount.toStringAsFixed(2)),
      cost.currency,
    );
  }

  /// حساب الاهلاك بطريقة المتناقص
  static Money calculateDecliningBalance(
    Money bookValue,
    Money originalCost,
    int usefulLifeMonths,
    double rate, // معدل الاهلاك المتناقص (مثلاً 0.2 للـ 20%)
  ) {
    if (usefulLifeMonths <= 0 || bookValue.amount <= 0) {
      return Money.zero(bookValue.currency);
    }
    
    final annualRate = rate > 0 ? rate : (2.0 / (usefulLifeMonths / 12));
    final monthlyRate = annualRate / 12;
    final depreciationAmount = bookValue.amount * monthlyRate;
    
    return Money.fromDecimal(
      Decimal.parse(depreciationAmount.toStringAsFixed(2)),
      bookValue.currency,
    );
  }
}
