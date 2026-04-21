import 'package:audit_log/audit_log.dart';
import 'dart:convert';

class AuditLogModel {
  final String id;
  final String userId;
  final String username;
  final String action;
  final String entity;
  final String? entityId;
  final String? changes;
  final String? description;
  final String timestamp;
  final String? ipAddress;
  final String? userAgent;

  AuditLogModel({
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

  factory AuditLogModel.fromJson(Map<String, dynamic> json) {
    return AuditLogModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      username: json['username'] as String,
      action: json['action'] as String,
      entity: json['entity'] as String,
      entityId: json['entityId'] as String?,
      changes: json['changes'] as String?,
      description: json['description'] as String?,
      timestamp: json['timestamp'] as String,
      ipAddress: json['ipAddress'] as String?,
      userAgent: json['userAgent'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'action': action,
      'entity': entity,
      if (entityId != null) 'entityId': entityId,
      if (changes != null) 'changes': changes,
      if (description != null) 'description': description,
      'timestamp': timestamp,
      if (ipAddress != null) 'ipAddress': ipAddress,
      if (userAgent != null) 'userAgent': userAgent,
    };
  }

  static AuditLogModel fromEntity(AuditLog entity) {
    return AuditLogModel(
      id: entity.id.value,
      userId: entity.userId.value,
      username: entity.username,
      action: entity.action.name,
      entity: entity.entity,
      entityId: entity.entityId,
      changes: entity.changes != null ? jsonEncode(entity.changes) : null,
      description: entity.description,
      timestamp: entity.timestamp.toIso8601String(),
      ipAddress: entity.ipAddress,
      userAgent: entity.userAgent,
    );
  }

  AuditLog toEntity() {
    return AuditLog(
      id: UniqueId.fromUniqueString(id),
      userId: UniqueId.fromUniqueString(userId),
      username: username,
      action: AuditAction.values.firstWhere((e) => e.name == action),
      entity: entity,
      entityId: entityId,
      changes: changes != null ? jsonDecode(changes) as Map<String, dynamic> : null,
      description: description,
      timestamp: DateTime.parse(timestamp),
      ipAddress: ipAddress,
      userAgent: userAgent,
    );
  }
}
