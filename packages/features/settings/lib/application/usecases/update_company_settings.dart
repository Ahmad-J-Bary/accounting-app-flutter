import 'package:dartz/dartz.dart';
import 'package:foundation/foundation.dart';
import 'package:settings/settings.dart';

class UpdateCompanySettingsParams {
  final String name;
  final String? logo;
  final String address;
  final String phone;
  final String email;
  final String taxNumber;
  final Currency? currency;
  final DateTime? fiscalYearStart;

  UpdateCompanySettingsParams({
    required this.name,
    this.logo,
    required this.address,
    required this.phone,
    required this.email,
    required this.taxNumber,
    this.currency,
    this.fiscalYearStart,
  });
}

class UpdateCompanySettingsUseCase extends UseCase<CompanySettings, UpdateCompanySettingsParams> {
  final SettingsRepository<CompanySettings> repository;

  UpdateCompanySettingsUseCase(this.repository);

  @override
  Future<Either<Failure, CompanySettings>> call(UpdateCompanySettingsParams params) async {
    final loadResult = await repository.load();
    
    return loadResult.fold(
      (failure) => Left(failure),
      (currentSettings) async {
        final updatedSettings = currentSettings.copyWith(
          name: params.name,
          logo: params.logo,
          address: params.address,
          phone: params.phone,
          email: params.email,
          taxNumber: params.taxNumber,
          currency: params.currency ?? currentSettings.currency,
          fiscalYearStart: params.fiscalYearStart ?? currentSettings.fiscalYearStart,
          lastUpdated: DateTime.now(),
        );
        
        return await repository.save(updatedSettings).then((_) => Right(updatedSettings));
      },
    );
  }
}
