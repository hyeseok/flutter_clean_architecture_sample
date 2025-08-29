import 'package:dio/dio.dart';
import '../../services/auth_api.dart';
import '../../services/token_storage.dart';
import '../token_refresher.dart';
import '../../error/exceptions.dart';

class RefreshTokenInterceptor extends Interceptor {
  final TokenRefresher refresher;
  final TokenStorage tokenStorage;
  final AuthApi authApi;

  RefreshTokenInterceptor({
    required this.refresher,
    required this.tokenStorage,
    required this.authApi,
  });

  bool _shouldHandle401(Response? res) {
    final status = res?.statusCode;
    final uri = res?.requestOptions.uri;
    if (status != 401) return false;
    if (uri == null) return false;
    // refresh endpoint 자기 자신은 제외(무한 루프 방지)
    if (authApi.isRefreshEndpoint(uri)) return false;
    return true;
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final res = err.response;
    final req = err.requestOptions;

    if (_shouldHandle401(res)) {
      try {
        await refresher.refreshIfNeeded();

        // 새 토큰으로 헤더 업데이트
        final access = await tokenStorage.getAccessToken();
        final newOptions = _cloneAsNewRequest(req, accessToken: access);

        final dio = err.requestOptions.extra['dio_instance'] as Dio?;
        if (dio == null) {
          final req = err.requestOptions;
          final fallback = Dio(BaseOptions(
            baseUrl: req.baseUrl,
            connectTimeout: req.connectTimeout,
            receiveTimeout: req.receiveTimeout,
            sendTimeout: req.sendTimeout,
            headers: req.headers,
            responseType: req.responseType,
            contentType: req.contentType,
            followRedirects: req.followRedirects,
            validateStatus: req.validateStatus,
          ));
          final retried = await fallback.fetch(req);
          return handler.resolve(retried);
        }

        // 평소에는 원래 dio로 재시도
        final retried = await dio.fetch(newOptions); // newOptions는 Authorization 갱신된 RequestOptions
        return handler.resolve(retried);
      } catch (e) {
        // 리프레시 실패 → 세션 종료
        return handler.reject(
          DioException(
            requestOptions: req,
            error: UnauthenticatedException(message: '세션이 만료되었습니다. 다시 로그인해주세요.'),
            type: DioExceptionType.badResponse,
            response: res,
          ),
        );
      }
    }

    handler.next(err);
  }

  RequestOptions _cloneAsNewRequest(RequestOptions req, {String? accessToken}) {
    final headers = Map<String, dynamic>.from(req.headers);
    if (accessToken != null && accessToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $accessToken';
    }
    return RequestOptions(
      path: req.path,
      method: req.method,
      headers: headers,
      queryParameters: req.queryParameters,
      data: req.data,
      baseUrl: req.baseUrl,
      connectTimeout: req.connectTimeout,
      sendTimeout: req.sendTimeout,
      receiveTimeout: req.receiveTimeout,
      extra: req.extra,
      contentType: req.contentType,
      responseType: req.responseType,
      followRedirects: req.followRedirects,
      validateStatus: req.validateStatus,
    );
  }
}
