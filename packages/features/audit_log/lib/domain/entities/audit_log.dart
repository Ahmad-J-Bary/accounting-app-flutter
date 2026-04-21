import 'package:equatable/equatable.dart';
import 'package:foundation/foundation.dart';

enum AuditAction { create, update, delete, login, logout, export, import, custom }

class AuditLog extends Equatable {
  final UniqueId id;
  final UniqueId userId;
  final String username;
  final AuditAction action;
  final String entity;
  final String? entityId;
  final Map<String, dynamic>? changes;
  final String? description;
  final DateTime timestamp;
  final String? ipAddress;
  final String? userAgent;

  const AuditLog({
    required this.id,
    required this.userId,
    required this.username,
    required this.action,
    required this.entity,
    this.entityId,
    this.changes,
    this.description,
    required this.timestamp,
    this.ipAddress,
    this.userAgent,
  });

  AuditLog copyWith({
    UniqueId? id,
    UniqueId? userId,
    String? username,
    AuditAction? action,
    String? entity,
    String? entityId,
    Map<String, dynamic>? changes,
    String? description,
    DateTime? timestamp,
    String? ipAddress,
    String? userAgent,
  }) {
    return AuditLog(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      action: action ?? this.action,
      entity: entity ?? this.entity,
      entityId: entityId ?? this.entityId,
      changes: changes ?? this.changes,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      ipAddress: ipAddress ?? this.ipAddress,
      userAgent: userAgent ?? this.userAgent,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        username,
        action,
        entity,
        entityId,
        changes,
        description,
        timestamp,
        ipAddress,
        userAgent,
      ];
}
