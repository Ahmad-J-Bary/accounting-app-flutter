import 'package:dartz/dartz.dart';
import 'package:foundation/foundation.dart';
import 'package:settings/settings.dart';

class UpdateAppSettingsParams {
  final AppTheme? theme;
  final AppLanguage? language;
  final bool? notificationsEnabled;
  final bool? soundEnabled;

  UpdateAppSettingsParams({
    this.theme,
    this.language,
    this.notificationsEnabled,
    this.soundEnabled,
  });
}

class UpdateAppSettingsUseCase extends UseCase<AppSettings, UpdateAppSettingsParams> {
  final SettingsRepository<AppSettings> repository;

  UpdateAppSettingsUseCase(this.repository);

  @override
  Future<Either<Failure, AppSettings>> call(UpdateAppSettingsParams params) async {
    final loadResult = await repository.load();
    
    return loadResult.fold(
      (failure) => Left(failure),
      (currentSettings) async {
        final updatedSettings = currentSettings.copyWith(
          theme: params.theme ?? currentSettings.theme,
          language: params.language ?? currentSettings.language,
          notificationsEnabled: params.notificationsEnabled ?? currentSettings.notificationsEnabled,
          soundEnabled: params.soundEnabled ?? currentSettings.soundEnabled,
          lastUpdated: DateTime.now(),
        );
        
        return await repository.save(updatedSettings).then((_) => Right(updatedSettings));
      },
    );
  }
}
