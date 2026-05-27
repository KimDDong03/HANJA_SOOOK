import 'app_exception.dart';

enum FailureType {
  unknown,
  validation,
  network,
  notFound,
  unauthorized,
  server,
}

class Failure {
  const Failure({
    required this.message,
    this.type = FailureType.unknown,
    this.cause,
  });

  factory Failure.fromException(AppException exception) {
    return Failure(
      message: exception.userMessage,
      type: switch (exception.code) {
        AppExceptionCode.validation => FailureType.validation,
        AppExceptionCode.network => FailureType.network,
        AppExceptionCode.notFound => FailureType.notFound,
        AppExceptionCode.unauthorized => FailureType.unauthorized,
        AppExceptionCode.server => FailureType.server,
        AppExceptionCode.unknown => FailureType.unknown,
      },
      cause: exception,
    );
  }

  factory Failure.unknown([Object? cause]) {
    return Failure(message: '알 수 없는 문제가 발생했습니다.', cause: cause);
  }

  final String message;
  final FailureType type;
  final Object? cause;
}
