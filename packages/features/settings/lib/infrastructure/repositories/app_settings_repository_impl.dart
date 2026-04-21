import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:foundation/foundation.dart';
import 'package:settings/settings.dart';

class AppSettingsRepositoryImpl implements SettingsRepository<AppSettings> {
  static const String _settingsKey = 'app_settings';
  final SharedPreferences sharedPreferences;

  AppSettingsRepositoryImpl(this.sharedPreferences);

  @override
  Future<Either<Failure, AppSettings>> getById(UniqueId id) async {
    return load();
  }

  @override
  Future<Either<Failure, List<AppSettings>>> getAll() async {
    final result = await load();
    return result.fold((failure) => Left(failure), (settings) => Right([settings]));
  }

  @override
  Future<Either<Failure, AppSettings>> create(AppSettings entity) async {
    return save(entity).then((_) => Right(entity));
  }

  @override
  Future<Either<Failure, AppSettings>> update(AppSettings entity) async {
    return save(entity).then((_) => Right(entity));
  }

  @override
  Future<Either<Failure, Unit>> delete(UniqueId id) async {
    await sharedPreferences.remove(_settingsKey);
    return const Right(unit);
  }

  @override
  Future<Either<Failure, AppSettings>> load() async {
    try {
      final jsonString = sharedPreferences.getString(_settingsKey);
      
      if (jsonString == null) {
        // Return default settings
        final defaultSettings = AppSettings(
          id: UniqueId(),
          theme: AppTheme.system,
          language: AppLanguage.en,
          notificationsEnabled: true,
          soundEnabled: true,
          lastUpdated: DateTime.now(),
        );
        await save(defaultSettings);
        return Right(defaultSettings);
      }

      final model = AppSettingsModel.fromJsonString(jsonString);
      return Right(model.toEntity());
    } catch (e) {
      return Left(Failure(message: 'Failed to load settings: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> save(AppSettings settings) async {
    try {
      final model = AppSettingsModel.fromEntity(settings);
      await sharedPreferences.setString(_settingsKey, model.toJsonString());
      return const Right(unit);
    } catch (e) {
      return Left(Failure(message: 'Failed to save settings: ${e.toString()}'));
    }
  }
}
