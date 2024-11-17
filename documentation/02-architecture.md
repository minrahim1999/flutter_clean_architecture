# Architecture Overview

This document outlines the architectural principles and patterns used in our Flutter application.

## Clean Architecture

Our application follows Clean Architecture principles, divided into layers:

```
lib/
├── core/              # Core functionality and shared code
├── features/          # Feature modules
└── main.dart          # Application entry point
```

### Layers (from outside in)

1. **Presentation Layer** (`presentation/`)
   - Widgets
   - Pages
   - BLoC (Business Logic Component)
   ```dart
   features/
   └── home/
       └── presentation/
           ├── pages/
           ├── widgets/
           └── bloc/
   ```

2. **Domain Layer** (`domain/`)
   - Entities
   - Use Cases
   - Repository Interfaces
   ```dart
   features/
   └── home/
       └── domain/
           ├── entities/
           ├── repositories/
           └── usecases/
   ```

3. **Data Layer** (`data/`)
   - Models
   - Repositories Implementation
   - Data Sources
   ```dart
   features/
   └── home/
       └── data/
           ├── models/
           ├── repositories/
           └── datasources/
   ```

## Feature Structure

Each feature follows a modular structure:

```
features/
└── feature_name/
    ├── data/
    │   ├── datasources/
    │   │   ├── feature_remote_data_source.dart
    │   │   └── feature_local_data_source.dart
    │   ├── models/
    │   │   └── feature_model.dart
    │   └── repositories/
    │       └── feature_repository_impl.dart
    ├── domain/
    │   ├── entities/
    │   │   └── feature.dart
    │   ├── repositories/
    │   │   └── feature_repository.dart
    │   └── usecases/
    │       └── get_feature.dart
    └── presentation/
        ├── bloc/
        │   ├── feature_bloc.dart
        │   ├── feature_event.dart
        │   └── feature_state.dart
        ├── pages/
        │   └── feature_page.dart
        └── widgets/
            └── feature_widget.dart
```

## Core Module

The `core/` directory contains shared functionality:

```
core/
├── bloc/           # Global BLoCs
├── di/             # Dependency injection
├── error/          # Error handling
├── network/        # Network utilities
├── theme/          # Theme configuration
├── utils/          # Utility functions
└── widgets/        # Shared widgets
```

## Dependency Injection

We use `get_it` for dependency injection:

```dart
// lib/core/di/injection_container.dart

final sl = GetIt.instance;

Future<void> init() async {
  // BLoCs
  sl.registerFactory(() => HomeBloc(
    getHome: sl(),
    updateHome: sl(),
  ));

  // Use Cases
  sl.registerLazySingleton(() => GetHome(sl()));
  sl.registerLazySingleton(() => UpdateHome(sl()));

  // Repositories
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data Sources
  sl.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(client: sl()),
  );
}
```

## State Management

We use the BLoC (Business Logic Component) pattern:

```dart
// Example BLoC
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetHome getHome;
  final UpdateHome updateHome;

  HomeBloc({
    required this.getHome,
    required this.updateHome,
  }) : super(HomeInitial()) {
    on<GetHomeRequested>(_onGetHomeRequested);
    on<UpdateHomeRequested>(_onUpdateHomeRequested);
  }

  Future<void> _onGetHomeRequested(
    GetHomeRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    final result = await getHome(NoParams());
    result.fold(
      (failure) => emit(HomeError(message: failure.message)),
      (home) => emit(HomeLoaded(home: home)),
    );
  }
}
```

## Error Handling

Consistent error handling using Either from dartz:

```dart
// Repository Implementation
class HomeRepositoryImpl implements HomeRepository {
  @override
  Future<Either<Failure, Home>> getHome() async {
    try {
      final result = await remoteDataSource.getHome();
      return Right(result);
    } on ServerException {
      return Left(ServerFailure());
    } on CacheException {
      return Left(CacheFailure());
    }
  }
}
```

## Navigation

Using `go_router` for declarative routing:

```dart
// lib/core/router/app_router.dart

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfilePage(),
    ),
  ],
);
```

## Testing Strategy

1. **Unit Tests**
   - Use Cases
   - Repositories
   - BLoCs

2. **Widget Tests**
   - Individual Widgets
   - Pages
   - Navigation

3. **Integration Tests**
   - Feature Flows
   - End-to-End Scenarios

## Best Practices

1. **Dependency Inversion**
   - Define abstractions in domain layer
   - Implement in data layer

2. **Single Responsibility**
   - Each class has one responsibility
   - Each feature is independent

3. **Feature-First Structure**
   - Organize by feature, not by layer
   - Shared code in core

4. **Consistent Naming**
   - Follow naming conventions
   - Clear, descriptive names

## Code Generation

We use several code generation tools:

1. **build_runner**
   ```bash
   flutter pub run build_runner build
   ```

2. **Feature Generator**
   ```bash
   dart tools/scripts/create_feature.dart feature_name
   ```

## Next Steps

1. Learn about [Feature Development](03-feature-development.md)
2. Understand [State Management](04-state-management.md)
3. Read the [Testing Guide](05-testing.md)

---

Next: [Feature Development](03-feature-development.md)
