import 'package:foundation/foundation.dart';

class Money extends ValueObject<double> {
  @override
  final double value;

  const Money(this.value) : assert(value >= 0);

  factory Money.zero() => const Money(0);

  Money add(Money other) => Money(value + other.value);
  Money subtract(Money other) => Money(value - other.value);
  Money multiply(double factor) => Money(value * factor);

  bool get isZero => value == 0;
  bool get isPositive => value > 0;

  @override
  String toString() => value.toStringAsFixed(2);
}
