import 'package:shared/shared.dart';

class ServerFailure extends Failure {
  const ServerFailure([String message = 'Server error occurred']) : super([message]);
}

class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'Network error occurred']) : super([message]);
}

class CacheFailure extends Failure {
  const CacheFailure([String message = 'Cache error occurred']) : super([message]);
}

class ValidationFailure extends Failure {
  const ValidationFailure([String message = 'Validation failed']) : super([message]);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([String message = 'Resource not found']) : super([message]);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([String message = 'Unauthorized access']) : super([message]);
}
