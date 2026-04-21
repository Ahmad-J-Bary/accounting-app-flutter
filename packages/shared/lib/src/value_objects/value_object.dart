import 'package:equatable/equatable.dart';

abstract class ValueObject<T> extends Equatable {
  const ValueObject();
  T get value;

  @override
  List<Object?> get props => [value];
}
