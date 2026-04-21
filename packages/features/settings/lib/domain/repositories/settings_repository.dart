import 'package:dartz/dartz.dart';
import 'package:foundation/foundation.dart';
import 'package:settings/settings.dart';

abstract class SettingsRepository<T> extends Repository<T, UniqueId> {
  Future<Either<Failure, T>> load();
  Future<Either<Failure, Unit>> save(T settings);
}
