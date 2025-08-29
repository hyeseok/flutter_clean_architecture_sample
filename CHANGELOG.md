# Changelog · clean_architecture_sample

이 파일은 **clean_architecture_sample** 전체 프로젝트의 변경 이력을 기록합니다.  
형식은 [Keep a Changelog](https://keepachangelog.com/ko/1.1.0/), 버저닝은 [Semantic Versioning](https://semver.org/lang/ko/)을 따릅니다.

> **파일 위치:** 리포지토리 루트 `CHANGELOG.md`

## [Unreleased]
### Added
- (예시) 사용자 프로필 편집 플로우
- (예시) 앱 테마 다크/라이트 토글

### Changed
- (예시) API 오류 메시지 현지화(ko-KR)

### Fixed
- (예시) iOS 빌드 시 Interceptor 순서 의존성 문제

---

## [1.1.0] - 2025-08-29
### Added
- **Network core 확장:** `makeDio` 도입 및 공통 설정(`DioConfig`) 추가.
- **Interceptors:**
  - `AuthHeaderInterceptor`(Bearer 토큰/공통 헤더 주입)
  - `RefreshTokenInterceptor`(+ `TokenRefresher`로 동시성 안전 401 자동 토큰 갱신 & 재요청)
  - `RetryInterceptor`(지수 백오프, 기본 GET만 재시도)
  - `LoggingInterceptor`(디버그 빌드 전용 요청/응답/에러 로그)
- **Error 공통화:** `ApiException` 파생 타입(Unauthenticated/Forbidden/Server/Network/TimeoutX) 추가,  
  `ErrorMapper`가 `DioException`을 위 예외/문구로 매핑.

### Changed
- **DI 구성:** 리프레시 요청 전용 `Dio`와 앱 전역용 `Dio(instanceName: 'app_dio')`를 분리 등록해 순환 의존 방지.

### Fixed
- **타입 불일치 수정:** `final currentDio = Dio()..options = req` → **잘못된 타입 대입**을 수정.  
  `RequestOptions`에서 필요한 값만 뽑아 `BaseOptions`로 초기화 후 `fetch(req)` 사용.

### Code (excerpts)
#### `lib/core/network/make_dio.dart`
```dart
Dio makeDio({
  required DioConfig config,
  required TokenStorage tokenStorage,
  required AuthApi authApi,
  bool enableRetry = true,
  bool enableLogging = true,
}) {
  final dio = Dio(BaseOptions(
    baseUrl: config.baseUrl,
    connectTimeout: config.connectTimeout,
    receiveTimeout: config.receiveTimeout,
    headers: config.defaultHeaders,
    responseType: ResponseType.json,
    validateStatus: (s) => s != null && s > 0,
  ));

  // 재요청용 self 참조
  dio.interceptors.add(InterceptorsWrapper(onRequest: (opt, h) {
    opt.extra['dio_instance'] = dio;
    h.next(opt);
  }));

  final refresher = TokenRefresher(tokenStorage: tokenStorage, authApi: authApi);

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


---

## [1.0.1] - 2025-08-29
### Added
- **공통 로딩/에러 처리 분리:** UI/에러 처리를 모듈화하여 화면에서 `data` 렌더링에만 집중하도록 개선.
  - `lib/core/ui/widgets/common_loading.dart`
  - `lib/core/error/error_mapper.dart`
  - `lib/core/extensions/async_value_extensions.dart` (Riverpod `AsyncValue<T>` 확장)

### Changed
- **DogsPage**가 `whenOrDefault`를 사용하도록 변경(로딩/에러 공통 처리).

### Docs
- `lib/features/dogs/CHANGELOG.md` 초안 생성(모듈별 로그 시작).

### Code
#### `lib/core/ui/widgets/common_loading.dart`
```dart
import 'package:flutter/material.dart';

class CommonLoading extends StatelessWidget {
  const CommonLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
```

#### `lib/core/error/error_mapper.dart`
```dart
class ErrorMapper {
  static String toMessage(Object error) {
    try {
      // 프로젝트 표준에 맞춰 점진적으로 보강해 주세요.
      // if (error is DioException) { ... }
      if (error is FormatException) return '데이터 형식이 올바르지 않습니다.';
      return error.toString();
    } catch (_) {
      return '알 수 없는 오류가 발생했습니다.';
    }
  }
}
```

#### `lib/core/extensions/async_value_extensions.dart`
```dart
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../error/error_mapper.dart';
import '../ui/widgets/common_loading.dart';

extension AsyncValueX<T> on AsyncValue<T> {
  Widget whenOrDefault({
    required Widget Function(T data) data,
    Widget? loading,
    Widget Function(String message)? error,
  }) {
    return when(
      data: data,
      loading: () => loading ?? const CommonLoading(),
      error: (err, _) {
        final message = ErrorMapper.toMessage(err);
        if (error != null) return error(message);
        return Center(child: Text(message, textAlign: TextAlign.center));
      },
    );
  }

  R mapDataOr<R>({
    required R Function(T data) data,
    required R Function() orElseLoading,
    required R Function(String message) orElseError,
  }) {
    return when(
      data: data,
      loading: orElseLoading,
      error: (err, _) => orElseError(ErrorMapper.toMessage(err)),
    );
  }

  String? errorMessageOrNull() {
    return maybeWhen(
      error: (err, _) => ErrorMapper.toMessage(err),
      orElse: () => null,
    );
  }
}
```


#### 적용 예시 (`lib/features/dogs/presentation/dogs_page.dart`)
```dart
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/extensions/async_value_extensions.dart';
import '../providers/dogs_providers.dart'; // AsyncValue<List<Dog>> 제공

class DogsPage extends ConsumerWidget {
  const DogsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dogsAsync = ref.watch(dogsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Dogs')),
      body: dogsAsync.whenOrDefault(
        data: (dogs) => ListView.builder(
          itemCount: dogs.length,
          itemBuilder: (_, i) => ListTile(title: Text(dogs[i].name)),
        ),
      ),
    );
  }
}
```

---

## [1.0.0] - 2025-08-28
### Added
- **클린 아키텍처 스캐폴드:** `domain / data / presentation / core` 기본 레이어.
- **DI(get_it):** `sl`(GetIt.instance) 기반 DI 초기 세팅.
- **API 클라이언트:** `Dio` 기본 옵션/인터셉터(로깅, 헤더 주입) 뼈대.
- **토큰/세션:** `TokenStorage`(secure storage) 및 **refreshToken** 흐름용 인터페이스 스텁. (예정)
- **유저 모듈(예시):** `GetBreedRandombImage`, `GetBreeds`, `GetRandomImage` 유스케이스 예시 및 Providers/DogProviders 스텁.
- **라우팅:** goRoute 라우팅 구조 및 샘플 화면.

### Notes
- 초기 버전은 참조 구현 위주로, 실제 서비스 연동 시 각 모듈별 DTO/엔드포인트/인터셉터 정책을 프로젝트 요구사항에 맞춰 보강 필요.
- 리프레시 토큰 동작은 테스트 더블(Fake/Mock) 후 통합 테스트로 보완 예정.
- Android/iOS/Web 멀티플랫폼 고려: 보안 저장소/쿠키/서비스워커 등 차이점 문서화 예정.

---

## 릴리스 가이드
- 새 변경사항은 먼저 **[Unreleased]** 섹션에 누적.
- 릴리스 시점에 해당 항목을 새로운 버전 섹션으로 이동하고 날짜를 기입.
- 권장 커밋 규칙: **Conventional Commits** (`feat:`, `fix:`, `refactor:`, `docs:`, `chore:` …).
- 태그/푸시 예시:
  ```sh
  git tag v0.2.0 && git push --tags
  ```
