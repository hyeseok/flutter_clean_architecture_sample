import 'dart:math';
import 'package:dio/dio.dart';

typedef ShouldRetry = bool Function(DioException e, RequestOptions options);

class RetryInterceptor extends Interceptor {
  final int maxRetries;
  final Duration baseDelay;
  final ShouldRetry shouldRetry;

  RetryInterceptor({
    this.maxRetries = 2,
    this.baseDelay = const Duration(milliseconds: 300),
    ShouldRetry? shouldRetry,
  }) : shouldRetry = shouldRetry ?? _defaultShouldRetry;

  static bool _defaultShouldRetry(DioException e, RequestOptions ro) {
    // idempotent 요청만 재시도하고 싶다면 method 체크(예: GET)
    final isGet = ro.method.toUpperCase() == 'GET';
    if (!isGet) return false;

    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return true;
    }
    return false;
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final options = err.requestOptions;
    int attempt = (options.extra['retry_attempt'] as int?) ?? 0;

    if (attempt >= maxRetries || !shouldRetry(err, options)) {
      return handler.next(err);
    }

    attempt += 1;
    options.extra['retry_attempt'] = attempt;

    final delay = baseDelay * pow(2, attempt - 1).toInt();
    await Future<void>.delayed(delay);

    final dio = options.extra['dio_instance'] as Dio?;
    if (dio == null) return handler.next(err); // 안전망

    try {
      final response = await dio.fetch(options);
      handler.resolve(response);
    } catch (e) {
      handler.next(e is DioException ? e : err);
    }
  }
}
