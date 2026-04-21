import 'package:equatable/equatable.dart';

class Percentage extends Equatable {
  final double value;

  const Percentage(this.value) : assert(value >= 0 && value <= 100, 'Percentage must be between 0 and 100');

  static const Percentage zero = Percentage(0);
  static const Percentage hundred = Percentage(100);

  bool get isZero => value == 0;
  bool get isHundred => value == 100;
  bool get isPositive => value > 0;

  Percentage operator +(Percentage other) => Percentage(value + other.value);
  Percentage operator -(Percentage other) => Percentage(value - other.value);
  Percentage operator *(double multiplier) => Percentage(value * multiplier);
  Percentage operator /(double divisor) => Percentage(value / divisor);

  Percentage copyWith({double? value}) => Percentage(value ?? this.value);

  @override
  String toString() => '${value.toStringAsFixed(2)}%';

  @override
  List<Object?> get props => [value];
}
