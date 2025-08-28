# Dogs App

A small, **buildable Flutter sample** that consumes the public Dog CEO API to showcase a clean, **Feature‑oriented architecture** using **Riverpod (state)** + **get\_it (DI)** + **go\_router (routing)** + **Dio (HTTP)**.

> Features: list all breeds, show a random image, and show a breed‑specific random image.

---

## ✨ Tech Stack

* **Flutter** (Mobile & Web)
* **Riverpod** — app state & derived state
* **get\_it** — dependency injection container
* **go\_router** — declarative routing
* **Dio** — HTTP client

---

## 🧭 Architecture Overview

We use a Clean Architecture variant with vertical **Feature slices**.

```
Presentation (Riverpod Pages/Providers)
        ↓
Domain (Entities, Repositories[abstract], UseCases)
        ↑
Data (DTO/Models, RemoteDataSource, Repositories[impl])
```

* **Presentation → Domain ← Data** dependency rule
* Features are **plug‑in like**: each feature owns its `di.dart` and `routes.dart`, and the app wires them in `app/`.

---

## 📂 Folder Structure

```
lib/
├─ app/
│  ├─ di.dart                # Global DI bootstrap (get_it) + feature module registration
│  ├─ router.dart            # go_router: merges feature routes
│  └─ app.dart               # MaterialApp + Theme
├─ core/
│  └─ network/
│     └─ dio_factory.dart    # Base Dio configuration (baseUrl, timeouts, interceptors)
├─ features/
│  └─ dogs/
│     ├─ domain/
│     │  ├─ entities/        # Breed, DogImage (pure data)
│     │  ├─ repositories/    # DogRepository (abstract contracts)
│     │  └─ usecases/        # GetBreeds, GetRandomImage, GetBreedRandomImage
│     ├─ data/
│     │  ├─ models/          # DTOs for API responses
│     │  ├─ datasources/     # DogRemoteDataSource (Dio)
│     │  └─ repositories/    # DogRepositoryImpl (maps DTO → Entity)
│     ├─ presentation/
│     │  ├─ providers/       # Riverpod providers & Notifiers
│     │  └─ pages/           # BreedsPage, RandomPage, BreedRandomPage (UI)
│     ├─ routes.dart         # Feature routes (go_router)
│     └─ di.dart             # Feature DI (registerDogsModule)
└─ main.dart                 # Bootstrap ProviderScope + initAppDI
```

### Why Feature‑oriented?

* Evaluators see **one feature end‑to‑end** (Domain↔Data↔Presentation) at a glance
* Easy to duplicate the feature folder to add new modules (e.g., `cats/`)
* Feature DI + Routes are **composable** in the app layer

---

## 🔌 Dependency Injection Strategy

* **`app/di.dart`** registers global infrastructure (Dio) and invokes each feature’s `register*Module()`.
* **`features/dogs/di.dart`** registers *only* Dogs’ DataSource/Repository (and optionally UseCases) into **get\_it**.
* Presentation (Riverpod) resolves UseCases via small **Provider adapters** that read from `sl<T>()`.

```dart
// Provider adapter example
final getBreedsUsecaseProvider = Provider<GetBreeds>((ref) => GetBreeds(sl()));
```

This keeps **construction/wiring** in DI while **state** and **lifecycle** stay with Riverpod.

---

## 🌐 API Endpoints (Dog CEO)

* List all breeds: `GET /api/breeds/list/all`
* Random image: `GET /api/breeds/image/random`
* Random image by breed: `GET /api/breed/{breed}/images/random`
* Base URL: `https://dog.ceo`

> Authentication: none. CORS is generally enabled for Web.

---

## ▶️ Getting Started

### Prerequisites

* Flutter SDK 3.22+ (Dart 3.4+)
* Android/iOS tooling or Chrome for Web

### Install

```bash
flutter pub get
```

### Run (pick one)

```bash
# Mobile (Android emulator / iOS simulator)
flutter run

# Web (Chrome)
flutter run -d chrome
```

### Build

```bash
# Android
flutter build apk

# iOS
flutter build ios

# Web
flutter build web
```

---

## ⚙️ Configuration

* Base URL is set in `lib/core/network/dio_factory.dart`:

```dart
Dio makeDio() => Dio(BaseOptions(baseUrl: 'https://dog.ceo'));
```

Adjust interceptors (logging, retry, etc.) there as needed.

---

## 🧩 Key Files (Pointers)

* **App Bootstrap**: `main.dart`, `app/app.dart`, `app/di.dart`, `app/router.dart`
* **Dogs Feature**:

    * Domain: `features/dogs/domain/{entities,repositories,usecases}`
    * Data: `features/dogs/data/{models,datasources,repositories}`
    * Presentation: `features/dogs/presentation/{providers,pages}`
    * Wiring: `features/dogs/di.dart`, `features/dogs/routes.dart`

---

## 🧪 Testing (suggested)

* **Domain**: UseCase unit tests (mock Repository)
* **Data**: RepositoryImpl tests (mock DataSource) + DTO mapping tests
* **Presentation**: Provider/Notifier tests with Riverpod’s `ProviderContainer` & overrides

Example (pseudo):

```dart
final repo = FakeRepo();
final usecase = GetBreeds(repo);
expect(await usecase(), isA<List<Breed>>());
```

---

## 🧱 Conventions & Notes

* **DTO ↔ Entity mapping** lives **only** in Data layer
* UI never touches raw JSON; it reads **Entities** or **ViewModels**
* **Error handling** (simplified in sample) can be promoted to a `Failure` model & `Result<T>` wrapper
* **Refreshable** providers (`ref.refresh`) are used for one‑shot queries (e.g., breed random image)

---

## 🚀 Extending the Sample

* Add **search** on breeds with local filtering provider
* Add **favorites** with a simple local repository
* Add **design system** (`core/design_system/`) for tokens/components
* Add interceptors (caching, retry) in `dio_factory.dart`

---

## 📄 License

MIT (sample code). Replace as needed for your org.
