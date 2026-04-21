import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:settings/settings.dart';

// SharedPreferences Provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be initialized');
});

// Repository Provider
final appSettingsRepositoryProvider = Provider<AppSettingsRepositoryImpl>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AppSettingsRepositoryImpl(prefs);
});

// Use Cases Providers
final updateAppSettingsUseCaseProvider = Provider<UpdateAppSettingsUseCase>((ref) {
  final repository = ref.watch(appSettingsRepositoryProvider);
  return UpdateAppSettingsUseCase(repository);
});

// Settings State Provider
final appSettingsProvider = StateNotifierProvider<AppSettingsNotifier, AppSettings>((ref) {
  final useCase = ref.watch(updateAppSettingsUseCaseProvider);
  return AppSettingsNotifier(useCase);
});

class AppSettingsNotifier extends StateNotifier<AppSettings> {
  final UpdateAppSettingsUseCase _updateUseCase;

  AppSettingsNotifier(this._updateUseCase) : super(const AppSettings(
    id: UniqueId(),
    theme: AppTheme.system,
    language: AppLanguage.en,
    notificationsEnabled: true,
    soundEnabled: true,
    lastUpdated: DateTime.now(),
  )) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final repository = _updateUseCase.repository as AppSettingsRepositoryImpl;
    final result = await repository.load();
    result.fold(
      (failure) => null,
      (settings) => state = settings,
    );
  }

  Future<void> updateTheme(AppTheme theme) async {
    final result = await _updateUseCase(UpdateAppSettingsParams(theme: theme));
    result.fold(
      (failure) => null,
      (settings) => state = settings,
    );
  }

  Future<void> updateLanguage(AppLanguage language) async {
    final result = await _updateUseCase(UpdateAppSettingsParams(language: language));
    result.fold(
      (failure) => null,
      (settings) => state = settings,
    );
  }

  Future<void> toggleNotifications() async {
    final result = await _updateUseCase(UpdateAppSettingsParams(
      notificationsEnabled: !state.notificationsEnabled,
    ));
    result.fold(
      (failure) => null,
      (settings) => state = settings,
    );
  }

  Future<void> toggleSound() async {
    final result = await _updateUseCase(UpdateAppSettingsParams(
      soundEnabled: !state.soundEnabled,
    ));
    result.fold(
      (failure) => null,
      (settings) => state = settings,
    );
  }
}
