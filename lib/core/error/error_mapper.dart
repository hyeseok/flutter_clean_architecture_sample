
import 'package:dio/dio.dart';

import 'exceptions.dart';

class ErrorMapper {
  static String toMessage(Object error) {
    try {
      // 1) 이미 공통 예외면 바로 메시지
      if (error is ApiException) return error.message;

      // 2) DioException 상세 분기
      if (error is DioException) {
        final res = error.response;
        final uri = res?.requestOptions.uri ?? error.requestOptions.uri;

        switch (error.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.sendTimeout:
          case DioExceptionType.receiveTimeout:
            return TimeoutExceptionX(uri: uri).message;

          case DioExceptionType.badResponse:
            final status = res?.statusCode;
            if (status == 401) return UnauthenticatedException(uri: uri).message;
            if (status == 403) return ForbiddenException(uri: uri).message;
            if (status != null && status >= 500) {
              return ServerException(statusCode: status, uri: uri).message;
            }
            // 서버가 표준 에러 바디 {code,message}를 준다면 파싱해서 사용
            final serverMsg = _extractServerMessage(res?.data);
            return serverMsg ?? '요청 처리 중 문제가 발생했습니다. ($status)';

          case DioExceptionType.connectionError:
            return NetworkException(uri: error.requestOptions.uri).message;

          case DioExceptionType.cancel:
            return '요청이 취소되었습니다.';

          case DioExceptionType.unknown:
          default:
          // SocketException 등
            return '알 수 없는 오류가 발생했습니다.';
        }
      }

      // 3) 일반 예외
      if (error is FormatException) return '데이터 형식이 올바르지 않습니다.';
      return error.toString();
    } catch (_) {
      return 'Something went wrong';
    }
  }

  static String? _extractServerMessage(dynamic data) {
    try {
      if (data is Map<String, dynamic>) {
        // 서버 규격에 맞게 키 이름 조정
        return data['message'] as String? ?? data['error'] as String?;
      }
    } catch (_) {}
    return null;
  }
}