/// Domain Failures for Clean Architecture
sealed class Failure {
  const Failure(this.message, [this.code]);
  final String message;
  final String? code;

  @override
  String toString() => '$runtimeType: $message (${code ?? "no_code"})';
}

final class ServerFailure extends Failure {
  const ServerFailure(super.message, [super.code]);
}

final class AuthFailure extends Failure {
  const AuthFailure(super.message, [super.code]);
}

final class StorageFailure extends Failure {
  const StorageFailure(super.message, [super.code]);
}

final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection', super.code = 'NO_CONNECTION']);
}

final class ValidationFailure extends Failure {
  const ValidationFailure(super.message, [super.code]);
}
