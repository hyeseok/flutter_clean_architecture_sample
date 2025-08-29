import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      log('[REQ] ${options.method} ${options.uri}\nH: ${options.headers}\nQ: ${options.queryParameters}\nD: ${options.data}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      log('[RES] ${response.statusCode} ${response.requestOptions.uri}\nD: ${response.data}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      log('[ERR] ${err.requestOptions.uri} type=${err.type} status=${err.response?.statusCode}\nE: ${err.error}');
    }
    handler.next(err);
  }
}
