import 'package:equatable/equatable.dart';
import 'package:foundation/foundation.dart';

class ServerFailure extends Failure {
  final String message;

  const ServerFailure(this.message);

  @override
  List<Object?> get props => [message];
}
