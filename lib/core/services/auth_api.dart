class RefreshResult {
  final String accessToken;
  final String refreshToken;
  RefreshResult(this.accessToken, this.refreshToken);
}

abstract class AuthApi {
  /// refresh 토큰으로 새 토큰 발급
  Future<RefreshResult> refresh(String refreshToken);

  /// refresh 요청의 endpoint인지 식별 (무한 루프 방지)
  bool isRefreshEndpoint(Uri uri);
}