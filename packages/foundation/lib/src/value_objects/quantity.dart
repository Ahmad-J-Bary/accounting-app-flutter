import 'package:foundation/foundation.dart';

class Quantity extends ValueObject<double> {
  @override
  final double value;

  const Quantity(this.value) : assert(value >= 0);

  factory Quantity.zero() => const Quantity(0);

  Quantity add(Quantity other) => Quantity(value + other.value);
  Quantity subtract(Quantity other) => Quantity(value - other.value);

  bool get isZero => value == 0;
  bool get isPositive => value > 0;

  @override
  String toString() => value.toStringAsFixed(3);
}
