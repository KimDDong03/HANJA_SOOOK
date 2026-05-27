enum AppExceptionCode {
  unknown,
  validation,
  network,
  notFound,
  unauthorized,
  server,
}

class AppException implements Exception {
  const AppException({
    required this.message,
    this.code = AppExceptionCode.unknown,
    this.cause,
    this.stackTrace,
  });

  final String message;
  final AppExceptionCode code;
  final Object? cause;
  final StackTrace? stackTrace;

  String get userMessage => switch (code) {
    AppExceptionCode.validation => message,
    AppExceptionCode.network => '인터넷 연결을 확인한 뒤 다시 시도해주세요.',
    AppExceptionCode.notFound => '요청한 정보를 찾을 수 없습니다.',
    AppExceptionCode.unauthorized => '다시 로그인해주세요.',
    AppExceptionCode.server => '잠시 후 다시 시도해주세요.',
    AppExceptionCode.unknown => message,
  };

  @override
  String toString() => 'AppException($code): $message';
}
