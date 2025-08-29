import 'package:clean_architecture_sample/core/network/token_refresher.dart';
import 'package:dio/dio.dart';

import '../services/auth_api.dart';
import '../services/token_storage.dart';
import 'interceptors/auth_header_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/refresh_token_interceptor.dart';
import 'interceptors/retry_interceptor.dart';

class DioConfig {
  final String baseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Map<String, dynamic> defaultHeaders;

  DioConfig({
    required this.baseUrl,
    this.connectTimeout = const Duration(seconds: 30),
    this.receiveTimeout = const Duration(seconds: 30),
    this.defaultHeaders = const {},
  });
}

Dio makeDio({
  required DioConfig config,
  required TokenStorage tokenStorage,
  required AuthApi authApi,
  bool enableRetry = true,
  bool enableLogging = true,
}) {
  final options = BaseOptions(
    baseUrl: config.baseUrl,
    connectTimeout: config.connectTimeout,
    receiveTimeout: config.receiveTimeout,
    headers: config.defaultHeaders,
    responseType: ResponseType.json,
    validateStatus: (status) => status != null && status > 0, // 직접 처리
  );

  final dio = Dio(options);

  // extra에 자기 자신 참조 넣어 재시도/재요청 시 활용
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (opt, handler) {
      opt.extra['dio_instance'] = dio;
      handler.next(opt);
    },
  ));

  final refresher = TokenRefresher(tokenStorage: tokenStorage, authApi: authApi);

  // Interceptor 순서 매우 중요:
  // [request] logging → authHeader
  // [response/error] refreshToken → retry → logging
  if (enableLogging) dio.interceptors.add(LoggingInterceptor());
  dio.interceptors.add(AuthHeaderInterceptor(tokenStorage));
  dio.interceptors.add(RefreshTokenInterceptor(
    refresher: refresher,
    tokenStorage: tokenStorage,
    authApi: authApi,
  ));
  if (enableRetry) dio.interceptors.add(RetryInterceptor());

  return dio;
}