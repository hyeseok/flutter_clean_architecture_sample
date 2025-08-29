import 'package:dio/dio.dart';
import '../../services/token_storage.dart';

class AuthHeaderInterceptor extends Interceptor {
  final TokenStorage tokenStorage;

  AuthHeaderInterceptor(this.tokenStorage);

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await tokenStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    options.headers['Accept'] = 'application/json';
    options.headers['Content-Type'] = 'application/json';
    handler.next(options);
  }
}
