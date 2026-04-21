import 'package:equatable/equatable.dart';

class Currency extends Equatable {
  final String code;
  final String symbol;
  final int decimalPlaces;

  const Currency({
    required this.code,
    required this.symbol,
    this.decimalPlaces = 2,
  });

  static const Currency usd = Currency(code: 'USD', symbol: '\$');
  static const Currency eur = Currency(code: 'EUR', symbol: '€');
  static const Currency gbp = Currency(code: 'GBP', symbol: '£');
  static const Currency sar = Currency(code: 'SAR', symbol: '﷼');
  static const Currency aed = Currency(code: 'AED', symbol: 'د.إ');
  static const Currency egp = Currency(code: 'EGP', symbol: 'E£');

  bool get isUSD => code == 'USD';
  bool get isEUR => code == 'EUR';
  bool get isGBP => code == 'GBP';
  bool get isSAR => code == 'SAR';
  bool get isAED => code == 'AED';
  bool get isEGP => code == 'EGP';

  Currency copyWith({
    String? code,
    String? symbol,
    int? decimalPlaces,
  }) => Currency(
    code: code ?? this.code,
    symbol: symbol ?? this.symbol,
    decimalPlaces: decimalPlaces ?? this.decimalPlaces,
  );

  @override
  List<Object?> get props => [code, symbol, decimalPlaces];
}
