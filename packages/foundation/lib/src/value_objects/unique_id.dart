import 'package:foundation/foundation.dart';
import 'package:uuid/uuid.dart';

class UniqueId extends ValueObject<String> {
  @override
  final String value;

  const UniqueId._(this.value);

  factory UniqueId() {
    return UniqueId._(const Uuid().v4());
  }

  factory UniqueId.fromUniqueString(String uniqueId) {
    return UniqueId._(uniqueId);
  }

  @override
  String toString() => value;
}
