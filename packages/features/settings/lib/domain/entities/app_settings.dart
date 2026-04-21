import 'package:equatable/equatable.dart';
import 'package:foundation/foundation.dart';

enum AppTheme { light, dark, system }
enum AppLanguage { en, ar, fr }

class AppSettings extends Equatable {
  final UniqueId id;
  final AppTheme theme;
  final AppLanguage language;
  final bool notificationsEnabled;
  final bool soundEnabled;
  final DateTime lastUpdated;

  const AppSettings({
    required this.id,
    this.theme = AppTheme.system,
    this.language = AppLanguage.en,
    this.notificationsEnabled = true,
    this.soundEnabled = true,
    required this.lastUpdated,
  });

  AppSettings copyWith({
    UniqueId? id,
    AppTheme? theme,
    AppLanguage? language,
    bool? notificationsEnabled,
    bool? soundEnabled,
    DateTime? lastUpdated,
  }) {
    return AppSettings(
      id: id ?? this.id,
      theme: theme ?? this.theme,
      language: language ?? this.language,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props => [
        id,
        theme,
        language,
        notificationsEnabled,
        soundEnabled,
        lastUpdated,
      ];
}
