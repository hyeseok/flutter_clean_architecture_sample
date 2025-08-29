import 'package:clean_architecture_sample/core/network/dio_factory.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../core/services/auth_api.dart';
import '../core/services/token_storage.dart';
import '../features/dogs/di.dart' as dogs_di;

// 구현체는 프로젝트에 맞게
class SecureTokenStorage implements TokenStorage {
  @override
  Future<void> clear() {
    // TODO: implement clear
    throw UnimplementedError();
  }

  @override
  Future<String?> getAccessToken() {
    // TODO: implement getAccessToken
    throw UnimplementedError();
  }

  @override
  Future<String?> getRefreshToken() {
    // TODO: implement getRefreshToken
    throw UnimplementedError();
  }

  @override
  Future<void> saveTokens({required String accessToken, required String refreshToken}) {
    // TODO: implement saveTokens
    throw UnimplementedError();
  }
}

class AuthApiImpl implements AuthApi {
  final Dio dio;
  AuthApiImpl(this.dio);

  @override
  bool isRefreshEndpoint(Uri uri) => uri.path.endsWith('/auth/refresh');

  @override
  Future<RefreshResult> refresh(String refreshToken) async {
    final res = await dio.post('/auth/refresh', data: {'refreshToken': refreshToken});
    final data = res.data as Map<String, dynamic>;
    return RefreshResult(data['accessToken'], data['refreshToken']);
  }
}

final sl = GetIt.instance;

Future<void> initAppDI() async {
  // 토큰/리프레시 전용 dio (순환 방지 위해 authApi용은 최소 인터셉터)
  sl.registerLazySingleton<Dio>(() => Dio(BaseOptions(baseUrl: 'https://dog.ceo')));

  sl.registerLazySingleton<TokenStorage>(() => SecureTokenStorage());
  sl.registerLazySingleton<AuthApi>(() => AuthApiImpl(sl<Dio>()));

  // 앱 전역 dio
  sl.registerLazySingleton<Dio>(() {
    return makeDio(
      config: DioConfig(baseUrl: 'https://dog.ceo'),
      tokenStorage: sl<TokenStorage>(),
      authApi: sl<AuthApi>(),
      enableRetry: true,
      enableLogging: true,
    );
  }, instanceName: 'app_dio');

  dogs_di.registerDogsModules(sl);
}