import 'package:settings/settings.dart';
import 'dart:convert';

class AppSettingsModel {
  final String id;
  final String theme;
  final String language;
  final bool notificationsEnabled;
  final bool soundEnabled;
  final String lastUpdated;

  AppSettingsModel({
    required this.id,
    required this.theme,
    required this.language,
    required this.notificationsEnabled,
    required this.soundEnabled,
    required this.lastUpdated,
  });

  factory AppSettingsModel.fromJson(Map<String, dynamic> json) {
    return AppSettingsModel(
      id: json['id'] as String,
      theme: json['theme'] as String,
      language: json['language'] as String,
      notificationsEnabled: json['notificationsEnabled'] as bool,
      soundEnabled: json['soundEnabled'] as bool,
      lastUpdated: json['lastUpdated'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'theme': theme,
      'language': language,
      'notificationsEnabled': notificationsEnabled,
      'soundEnabled': soundEnabled,
      'lastUpdated': lastUpdated,
    };
  }

  static AppSettingsModel fromEntity(AppSettings entity) {
    return AppSettingsModel(
      id: entity.id.value,
      theme: entity.theme.name,
      language: entity.language.name,
      notificationsEnabled: entity.notificationsEnabled,
      soundEnabled: entity.soundEnabled,
      lastUpdated: entity.lastUpdated.toIso8601String(),
    );
  }

  AppSettings toEntity() {
    return AppSettings(
      id: UniqueId.fromUniqueString(id),
      theme: AppTheme.values.firstWhere((e) => e.name == theme),
      language: AppLanguage.values.firstWhere((e) => e.name == language),
      notificationsEnabled: notificationsEnabled,
      soundEnabled: soundEnabled,
      lastUpdated: DateTime.parse(lastUpdated),
    );
  }

  String toJsonString() => jsonEncode(toJson());
  
  static AppSettingsModel fromJsonString(String jsonString) {
    return fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }
}
