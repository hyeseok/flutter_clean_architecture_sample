class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? code; // 서버가 주는 에러코드가 있으면 넣기
  final Uri? uri;

  ApiException({
    required this.message,
    this.statusCode,
    this.code,
    this.uri,
  });

  @override
  String toString() => 'ApiException($statusCode, $code): $message';
}

class UnauthenticatedException extends ApiException {
  UnauthenticatedException({String message = '인증이 필요합니다.', Uri? uri})
      : super(message: message, statusCode: 401, uri: uri);
}

class ForbiddenException extends ApiException {
  ForbiddenException({String message = '접근 권한이 없습니다.', Uri? uri})
      : super(message: message, statusCode: 403, uri: uri);
}

class ServerException extends ApiException {
  ServerException({String message = '서버 오류가 발생했습니다.', int? statusCode, Uri? uri})
      : super(message: message, statusCode: statusCode, uri: uri);
}

class NetworkException extends ApiException {
  NetworkException({String message = '네트워크 연결을 확인해주세요.', Uri? uri})
      : super(message: message, statusCode: null, uri: uri);
}

class TimeoutExceptionX extends ApiException {
  TimeoutExceptionX({String message = '요청이 시간 초과되었습니다.', Uri? uri})
      : super(message: message, statusCode: null, uri: uri);
}
