
import 'package:clean_architecture_sample/core/result/failures.dart';
import 'package:dio/dio.dart';


class ErrorMapper {
  static Failure toFailure(Object error) {
    if (error is DioException) {
      final s = error.response?.statusCode;

      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          return TimeoutFailure('요청이 시간 초과되었습니다.');

        case DioExceptionType.badResponse:
          if (s == 401) return AuthFailure('인증이 필요합니다.');
          if (s == 403) return ForbiddenFailure('접근 권한이 없습니다.');
          if (s == 404) return NotFoundFailure('리소스를 찾을 수 없습니다.');
          if (s != null && s >= 500) return ServerFailure('서버 오류가 발생했습니다.', status: s);
          return UnknownFailure('요청 처리 중 문제가 발생했습니다. (${s ?? 'unknown'})');

        case DioExceptionType.connectionError:
          return NetworkFailure('네트워크 연결을 확인해주세요.');

        case DioExceptionType.cancel:
          return UnknownFailure('요청이 취소되었습니다.');

        case DioExceptionType.unknown:

        default:
          return UnknownFailure('알 수 없는 오류가 발생했습니다.');
      }
    }
    if (error is FormatException) return ValidationFailure('데이터 형식이 올바르지 않습니다.');
    return UnknownFailure(error.toString());
  }

  static String toMessage(Object error) => toFailure(error).message;
}