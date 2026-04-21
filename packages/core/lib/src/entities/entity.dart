import 'package:equatable/equatable.dart';
import 'package:shared/shared.dart';

abstract class Entity extends Equatable {
  final UniqueId id;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Entity({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, createdAt, updatedAt];
}
