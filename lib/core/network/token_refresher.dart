import 'dart:async';
import '../services/auth_api.dart';
import '../services/token_storage.dart';
import '../error/exceptions.dart';

class TokenRefresher {
  final TokenStorage tokenStorage;
  final AuthApi authApi;

  Completer<void>? _refreshing;

  TokenRefresher({required this.tokenStorage, required this.authApi});

  bool get isRefreshing => _refreshing != null;

  Future<void> refreshIfNeeded() async {
    if (_refreshing != null) {
      return _refreshing!.future; // 이미 진행 중이면 대기
    }

    final completer = Completer<void>();
    _refreshing = completer;

    try {
      final refreshToken = await tokenStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        throw UnauthenticatedException(message: '로그인 세션이 만료되었습니다.');
      }

      final result = await authApi.refresh(refreshToken);
      await tokenStorage.saveTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );
      completer.complete();
    } catch (e) {
      completer.completeError(e);
      rethrow;
    } finally {
      _refreshing = null;
    }
  }
}
