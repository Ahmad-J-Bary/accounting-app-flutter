import 'package:equatable/equatable.dart';
import 'package:foundation/foundation.dart';

class Warehouse extends Equatable {
  final UniqueId id;
  final String code;
  final String name;
  final String? address;
  final String? phone;
  final String? manager;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Warehouse({
    required this.id,
    required this.code,
    required this.name,
    this.address,
    this.phone,
    this.manager,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        code,
        name,
        address,
        phone,
        manager,
        isActive,
        createdAt,
        updatedAt,
      ];
}
