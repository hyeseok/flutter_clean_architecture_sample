import 'package:dio/dio.dart';

Dio makeDio() {
  final dio = Dio(BaseOptions(
    baseUrl: 'https://dog.ceo', // 공식 도메인 (구글 무료 api 제공)
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
  ));
  dio.interceptors.add(LogInterceptor(responseBody: false));
  return dio;
}