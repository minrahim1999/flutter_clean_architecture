# Architecture Patterns

This document details the architectural patterns and practices used in our Flutter Clean Architecture project.

## Table of Contents
1. [Clean Architecture](#clean-architecture)
2. [Design Patterns](#design-patterns)
3. [SOLID Principles](#solid-principles)
4. [Best Practices](#best-practices)

## Clean Architecture

### 1. Layer Separation

```dart
project/
├── domain/         # Business logic and entities
├── data/           # Data handling and repositories
└── presentation/   # UI and state management
```

### 2. Dependency Rule

- Inner layers don't know about outer layers
- Dependencies point inward
- Domain layer is independent
- Data layer depends on Domain
- Presentation depends on Domain

### 3. Layer Communication

```dart
// Domain Layer - Entity
class User extends Equatable {
  final String id;
  final String name;
  
  const User({required this.id, required this.name});
  
  @override
  List<Object?> get props => [id, name];
}

// Domain Layer - Repository Interface
abstract class UserRepository {
  Future<Either<Failure, User>> getUser(String id);
}

// Data Layer - Repository Implementation
class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;
  final UserLocalDataSource localDataSource;
  
  const UserRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });
  
  @override
  Future<Either<Failure, User>> getUser(String id) async {
    try {
      final user = await remoteDataSource.getUser(id);
      await localDataSource.cacheUser(user);
      return Right(user);
    } on Exception catch (e) {
      return Left(ServerFailure());
    }
  }
}

// Presentation Layer - BLoC
class UserBloc extends Bloc<UserEvent, UserState> {
  final GetUser getUser;
  
  UserBloc({required this.getUser}) : super(UserInitial()) {
    on<LoadUser>(_onLoadUser);
  }
  
  Future<void> _onLoadUser(
    LoadUser event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    
    final result = await getUser(event.id);
    result.fold(
      (failure) => emit(UserError(failure.message)),
      (user) => emit(UserLoaded(user)),
    );
  }
}
```

## Design Patterns

### 1. Repository Pattern

```dart
// Repository Interface
abstract class Repository<T> {
  Future<Either<Failure, T>> get(String id);
  Future<Either<Failure, List<T>>> getAll();
  Future<Either<Failure, Unit>> save(T item);
  Future<Either<Failure, Unit>> delete(String id);
}

// Generic Repository Implementation
class RepositoryImpl<T> implements Repository<T> {
  final RemoteDataSource<T> remoteDataSource;
  final LocalDataSource<T> localDataSource;
  final NetworkInfo networkInfo;
  
  const RepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });
  
  @override
  Future<Either<Failure, T>> get(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final remote = await remoteDataSource.get(id);
        await localDataSource.cache(remote);
        return Right(remote);
      } on Exception {
        return Left(ServerFailure());
      }
    } else {
      try {
        final local = await localDataSource.get(id);
        return Right(local);
      } on Exception {
        return Left(CacheFailure());
      }
    }
  }
}
```

### 2. Factory Pattern

```dart
// Abstract Factory
abstract class DataSourceFactory {
  RemoteDataSource createRemoteDataSource();
  LocalDataSource createLocalDataSource();
}

// Concrete Factory
class UserDataSourceFactory implements DataSourceFactory {
  @override
  RemoteDataSource createRemoteDataSource() {
    return UserRemoteDataSource(
      client: sl<HttpClient>(),
      tokenManager: sl<TokenManager>(),
    );
  }
  
  @override
  LocalDataSource createLocalDataSource() {
    return UserLocalDataSource(
      database: sl<Database>(),
    );
  }
}
```

### 3. Singleton Pattern

```dart
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;
  
  factory DatabaseHelper() {
    return _instance;
  }
  
  DatabaseHelper._internal();
  
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }
  
  Future<Database> _initDatabase() async {
    // Database initialization
  }
}
```

## SOLID Principles

### 1. Single Responsibility

```dart
// Good: Each class has one responsibility
class UserRepository {
  Future<User> getUser(String id);
}

class UserCache {
  Future<void> cacheUser(User user);
}

class UserValidator {
  bool validateUser(User user);
}

// Bad: Multiple responsibilities
class UserManager {
  Future<User> getUser(String id);
  Future<void> cacheUser(User user);
  bool validateUser(User user);
  void updateUI(User user);
}
```

### 2. Open/Closed

```dart
// Open for extension, closed for modification
abstract class AuthenticationMethod {
  Future<User> authenticate();
}

class EmailAuthentication implements AuthenticationMethod {
  @override
  Future<User> authenticate() {
    // Email authentication
  }
}

class BiometricAuthentication implements AuthenticationMethod {
  @override
  Future<User> authenticate() {
    // Biometric authentication
  }
}
```

### 3. Liskov Substitution

```dart
abstract class Storage {
  Future<void> save(String key, String value);
  Future<String?> get(String key);
}

class SecureStorage implements Storage {
  @override
  Future<void> save(String key, String value) {
    // Encrypted storage
  }
  
  @override
  Future<String?> get(String key) {
    // Decrypted retrieval
  }
}

class CacheStorage implements Storage {
  @override
  Future<void> save(String key, String value) {
    // Cache storage
  }
  
  @override
  Future<String?> get(String key) {
    // Cache retrieval
  }
}
```

### 4. Interface Segregation

```dart
// Good: Segregated interfaces
abstract class UserReader {
  Future<User> getUser(String id);
}

abstract class UserWriter {
  Future<void> saveUser(User user);
}

abstract class UserDeleter {
  Future<void> deleteUser(String id);
}

// Implementation can choose which interfaces to implement
class UserRepository implements UserReader, UserWriter {
  @override
  Future<User> getUser(String id) {
    // Implementation
  }
  
  @override
  Future<void> saveUser(User user) {
    // Implementation
  }
}
```

### 5. Dependency Inversion

```dart
// High-level module depends on abstraction
class UserBloc {
  final UserRepository repository;
  
  UserBloc({required this.repository});
}

// Low-level module implements abstraction
class UserRepositoryImpl implements UserRepository {
  final RemoteDataSource remoteDataSource;
  final LocalDataSource localDataSource;
  
  UserRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });
}
```

## Best Practices

1. **Dependency Injection**
   - Use GetIt for service location
   - Register dependencies at app startup
   - Use factories for scoped instances

2. **Error Handling**
   - Use Either type for error handling
   - Create specific failure classes
   - Handle errors at appropriate levels

3. **Testing**
   - Write tests for each layer
   - Mock dependencies
   - Use test doubles appropriately

4. **Code Organization**
   - Feature-first organization
   - Consistent file naming
   - Clear module boundaries

## Next Steps

1. Review the [CODE_STYLE](CODE_STYLE.md) guide
2. Check the [DEPENDENCY_MANAGEMENT](DEPENDENCY_MANAGEMENT.md) guide
3. Read the [TEST_CONVENTIONS](TEST_CONVENTIONS.md) guide
