# DEPENDENCY MANAGEMENT

This document outlines our approach to managing dependencies in the Flutter project.

## Table of Contents
1. [Package Management](#package-management)
2. [Version Control](#version-control)
3. [Dependency Injection](#dependency-injection)
4. [Best Practices](#best-practices)

## Package Management

### 1. Core Dependencies

```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_bloc: ^8.1.6
  equatable: ^2.0.5

  # Navigation
  go_router: ^13.0.0

  # Network
  dio: ^5.4.0
  retrofit: ^4.0.3

  # Local Storage
  hive: ^2.2.3
  shared_preferences: ^2.2.2

  # UI Components
  flutter_screenutil: ^5.9.0
  cached_network_image: ^3.3.1

  # Authentication
  firebase_auth: ^4.15.3
  google_sign_in: ^6.2.1

dev_dependencies:
  flutter_test:
    sdk: flutter

  # Code Generation
  build_runner: ^2.4.7
  retrofit_generator: ^8.0.6
  json_serializable: ^6.7.1

  # Testing
  bloc_test: ^9.1.5
  mockito: ^5.4.3
```

### 2. Version Management

```dart
// lib/core/config/app_config.dart
class AppConfig {
  static const String appVersion = '1.0.0';
  static const int buildNumber = 1;
  
  static const Map<String, String> requiredVersions = {
    'flutter': '>=3.19.0',
    'dart': '>=3.0.0 <4.0.0',
  };
  
  static const Map<String, String> apiVersions = {
    'core': 'v1',
    'auth': 'v2',
    'data': 'v1',
  };
}
```

### 3. Package Organization

```yaml
# Dependencies by feature
dependencies:
  # Core
  flutter_bloc: ^8.1.6
  equatable: ^2.0.5
  get_it: ^7.6.4
  injectable: ^2.3.2

  # Network
  dio: ^5.4.0
  retrofit: ^4.0.3
  connectivity_plus: ^5.0.2

  # Storage
  hive: ^2.2.3
  shared_preferences: ^2.2.2
  flutter_secure_storage: ^9.0.0

  # UI/UX
  flutter_screenutil: ^5.9.0
  cached_network_image: ^3.3.1
  shimmer: ^3.0.0
  lottie: ^2.7.0

  # Authentication
  firebase_auth: ^4.15.3
  google_sign_in: ^6.2.1
  local_auth: ^2.1.7

  # Analytics
  firebase_analytics: ^10.7.4
  firebase_crashlytics: ^3.4.8

  # Platform Integration
  url_launcher: ^6.2.2
  share_plus: ^7.2.1
  image_picker: ^1.0.5
```

## Version Control

### 1. Version Constraints

```yaml
# Good: Specific version constraints
dependencies:
  package_a: ^1.0.0  # Accept 1.0.0 to <2.0.0
  package_b: ~1.0.0  # Accept 1.0.0 to <1.1.0
  package_c: '>=1.0.0 <2.0.0'  # Explicit range

# Bad: Loose version constraints
dependencies:
  package_x: any  # Accept any version
  package_y: ^0.0.1  # Unstable version
  package_z: '>1.0.0'  # No upper bound
```

### 2. Version Resolution

```yaml
# dependency_overrides for conflict resolution
dependency_overrides:
  package_name: ^1.0.0
```

## Dependency Injection

### 1. Service Locator

```dart
// lib/core/di/injection.dart
@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
void configureDependencies() => getIt.init();

@module
abstract class AppModule {
  @singleton
  HttpClient get client => HttpClient();
  
  @singleton
  AuthenticationService get auth => AuthenticationService();
  
  @lazySingleton
  DatabaseHelper get database => DatabaseHelper();
}
```

### 2. Feature Registration

```dart
// lib/features/auth/di/auth_module.dart
@module
abstract class AuthModule {
  @lazySingleton
  AuthRepository get repository => AuthRepositoryImpl(
        remoteDataSource: getIt<AuthRemoteDataSource>(),
        localDataSource: getIt<AuthLocalDataSource>(),
      );
  
  @factory
  LoginUseCase get loginUseCase => LoginUseCase(
        repository: getIt<AuthRepository>(),
      );
  
  @factory
  AuthBloc get authBloc => AuthBloc(
        loginUseCase: getIt<LoginUseCase>(),
        logoutUseCase: getIt<LogoutUseCase>(),
      );
}
```

### 3. Scoped Dependencies

```dart
// lib/core/di/scopes.dart
@singleton
class SessionScope {
  final String sessionId;
  final DateTime createdAt;
  
  SessionScope(): 
    sessionId = uuid.v4(),
    createdAt = DateTime.now();
}

// Usage in feature
@injectable
class FeatureBloc {
  final SessionScope _session;
  
  FeatureBloc(this._session);
  
  String get currentSession => _session.sessionId;
}
```

## Best Practices

### 1. Package Selection Criteria

1. **Evaluation Checklist**
   - Active maintenance
   - Good documentation
   - High test coverage
   - Compatible license
   - Community support

2. **Version Selection**
   - Use stable versions
   - Avoid pre-releases in production
   - Consider LTS versions
   - Check breaking changes

### 2. Dependency Management

1. **Regular Updates**
   ```bash
   # Check outdated packages
   flutter pub outdated
   
   # Update dependencies
   flutter pub upgrade
   
   # Update with version constraints
   flutter pub upgrade --major-versions
   ```

2. **Security Checks**
   ```bash
   # Run security audit
   flutter pub audit
   
   # Check known vulnerabilities
   flutter pub deps --style=compact
   ```

### 3. Performance Considerations

1. **Package Size**
   - Monitor app size impact
   - Use tree-shaking
   - Consider platform-specific implementations

2. **Initialization**
   - Lazy loading when possible
   - Async initialization
   - Resource cleanup

### 4. Testing Strategy

1. **Mocking Dependencies**
   ```dart
   @GenerateMocks([HttpClient, AuthRepository])
   void main() {
     late MockHttpClient client;
     late MockAuthRepository repository;
     
     setUp(() {
       client = MockHttpClient();
       repository = MockAuthRepository();
     });
   }
   ```

2. **Integration Testing**
   ```dart
   void main() {
     IntegrationTestWidgetsFlutterBinding.ensureInitialized();
     
     testWidgets('full authentication flow', (tester) async {
       await tester.pumpWidget(const MyApp());
       // Test with real dependencies
     });
   }
   ```

## Next Steps

1. Review the [CODE_STYLE](CODE_STYLE.md) guide
2. Check the [TEST_CONVENTIONS](TEST_CONVENTIONS.md) guide
3. Read the [ARCHITECTURE_PATTERNS](ARCHITECTURE_PATTERNS.md) guide
