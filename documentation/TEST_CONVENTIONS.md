# TEST CONVENTIONS

This document outlines our testing conventions and best practices for the Flutter project.

## Table of Contents
1. [Testing Strategy](#testing-strategy)
2. [Unit Tests](#unit-tests)
3. [Widget Tests](#widget-tests)
4. [Integration Tests](#integration-tests)
5. [Best Practices](#best-practices)

## Testing Strategy

### 1. Test Pyramid

```
┌───────────┐
│Integration│  10%
├───────────┤
│  Widget   │  30%
├───────────┤
│   Unit    │  60%
└───────────┘
```

### 2. Test Organization

```
test/
├── core/                 # Core functionality tests
│   ├── bloc/            # Global BLoC tests
│   ├── network/         # Network tests
│   └── utils/           # Utility tests
├── features/            # Feature tests
│   └── feature_name/    # Individual feature tests
│       ├── data/        # Data layer tests
│       ├── domain/      # Domain layer tests
│       └── presentation/# UI layer tests
└── helpers/             # Test helpers and utilities
```

## Unit Tests

### 1. Naming Conventions

```dart
// Good: Clear and descriptive test names
void main() {
  group('UserRepository', () {
    test('should return user when getUser is called with valid ID', () {});
    test('should throw ServerException when server returns error', () {});
  });
}

// Bad: Unclear test names
void main() {
  group('repo', () {
    test('test1', () {});
    test('success case', () {});
  });
}
```

### 2. Test Structure

```dart
void main() {
  group('LoginUseCase', () {
    // 1. Setup/Fixtures
    late LoginUseCase useCase;
    late MockAuthRepository repository;

    setUp(() {
      repository = MockAuthRepository();
      useCase = LoginUseCase(repository);
    });

    // 2. Individual Tests
    test('should return UserCredential when login is successful', () async {
      // Arrange
      const email = 'test@example.com';
      const password = 'password123';
      final credential = MockUserCredential();
      when(() => repository.login(email, password))
          .thenAnswer((_) async => Right(credential));

      // Act
      final result = await useCase(
        LoginParams(email: email, password: password),
      );

      // Assert
      expect(result, Right(credential));
      verify(() => repository.login(email, password)).called(1);
    });

    test('should return AuthFailure when login fails', () async {
      // Arrange
      const email = 'test@example.com';
      const password = 'wrong_password';
      when(() => repository.login(email, password))
          .thenAnswer((_) async => Left(AuthFailure()));

      // Act
      final result = await useCase(
        LoginParams(email: email, password: password),
      );

      // Assert
      expect(result, Left(AuthFailure()));
      verify(() => repository.login(email, password)).called(1);
    });
  });
}
```

### 3. Mock Objects

```dart
@GenerateMocks([AuthRepository, NetworkInfo])
void main() {
  group('AuthRepositoryImpl', () {
    late AuthRepositoryImpl repository;
    late MockAuthRemoteDataSource remoteDataSource;
    late MockAuthLocalDataSource localDataSource;
    late MockNetworkInfo networkInfo;

    setUp(() {
      remoteDataSource = MockAuthRemoteDataSource();
      localDataSource = MockAuthLocalDataSource();
      networkInfo = MockNetworkInfo();
      repository = AuthRepositoryImpl(
        remoteDataSource: remoteDataSource,
        localDataSource: localDataSource,
        networkInfo: networkInfo,
      );
    });

    group('login', () {
      test('should return remote data when online', () async {
        // Arrange
        when(() => networkInfo.isConnected).thenAnswer((_) async => true);
        when(() => remoteDataSource.login(any(), any()))
            .thenAnswer((_) async => tUserModel);

        // Act
        final result = await repository.login(tEmail, tPassword);

        // Assert
        verify(() => remoteDataSource.login(tEmail, tPassword));
        expect(result, equals(Right(tUser)));
      });
    });
  });
}
```

## Widget Tests

### 1. Widget Testing

```dart
void main() {
  group('LoginScreen', () {
    late MockAuthBloc authBloc;

    setUp(() {
      authBloc = MockAuthBloc();
    });

    testWidgets('should show loading indicator when loading',
        (WidgetTester tester) async {
      // Arrange
      when(() => authBloc.state).thenReturn(AuthLoading());

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: authBloc,
            child: const LoginScreen(),
          ),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show error message when login fails',
        (WidgetTester tester) async {
      // Arrange
      const errorMessage = 'Invalid credentials';
      when(() => authBloc.state)
          .thenReturn(const AuthError(message: errorMessage));

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: authBloc,
            child: const LoginScreen(),
          ),
        ),
      );

      // Assert
      expect(find.text(errorMessage), findsOneWidget);
    });
  });
}
```

### 2. Golden Tests

```dart
void main() {
  group('CustomButton', () {
    testWidgets('matches golden file', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Center(
              child: CustomButton(
                text: 'Click Me',
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      // Act & Assert
      await expectLater(
        find.byType(CustomButton),
        matchesGoldenFile('goldens/custom_button.png'),
      );
    });

    testWidgets('matches golden file in dark theme',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(
            body: Center(
              child: CustomButton(
                text: 'Click Me',
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      // Act & Assert
      await expectLater(
        find.byType(CustomButton),
        matchesGoldenFile('goldens/custom_button_dark.png'),
      );
    });
  });
}
```

## Integration Tests

### 1. End-to-End Tests

```dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('tap on the floating action button, verify counter',
        (tester) async {
      // Load app widget.
      await tester.pumpWidget(const MyApp());

      // Verify the counter starts at 0.
      expect(find.text('0'), findsOneWidget);

      // Tap the '+' icon and trigger a frame.
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Verify the counter increments by 1.
      expect(find.text('1'), findsOneWidget);
    });
  });
}
```

### 2. Feature Flow Tests

```dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Flow', () {
    testWidgets('login flow test', (tester) async {
      // Start the app
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Find and tap login button
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      // Enter credentials
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'password123',
      );

      // Submit form
      await tester.tap(find.byKey(const Key('submit_button')));
      await tester.pumpAndSettle();

      // Verify navigation to home screen
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });
}
```

## Best Practices

### 1. Test Organization

1. **Group Related Tests**
   ```dart
   group('UserBloc', () {
     group('login', () {
       test('success case', () {});
       test('failure case', () {});
     });

     group('logout', () {
       test('success case', () {});
       test('failure case', () {});
     });
   });
   ```

2. **Setup Common Dependencies**
   ```dart
   void main() {
     late UserBloc bloc;
     late MockRepository repository;

     setUp(() {
       repository = MockRepository();
       bloc = UserBloc(repository);
     });

     tearDown(() {
       bloc.close();
     });
   }
   ```

### 2. Testing Patterns

1. **Given-When-Then**
   ```dart
   test('should emit error when network fails', () async {
     // Given
     when(() => repository.getUser())
         .thenThrow(NetworkException());

     // When
     bloc.add(const GetUser());

     // Then
     expectLater(bloc.stream, emits(const UserError()));
   });
   ```

2. **Arrange-Act-Assert**
   ```dart
   test('should validate email format', () {
     // Arrange
     const email = 'invalid-email';

     // Act
     final result = EmailValidator.validate(email);

     // Assert
     expect(result, false);
   });
   ```

### 3. Test Coverage

1. **Running Coverage**
   ```bash
   # Generate coverage report
   flutter test --coverage

   # Generate HTML report
   genhtml coverage/lcov.info -o coverage/html

   # Open coverage report
   open coverage/html/index.html
   ```

2. **Coverage Rules**
   - Unit Tests: 90% coverage
   - Widget Tests: 80% coverage
   - Integration Tests: 70% coverage

### 4. Test Maintenance

1. **Keep Tests Focused**
   ```dart
   // Good: Single responsibility
   test('should validate email format', () {
     expect(EmailValidator.validate('test@example.com'), true);
     expect(EmailValidator.validate('invalid-email'), false);
   });

   // Bad: Multiple responsibilities
   test('should validate form', () {
     expect(EmailValidator.validate('test@example.com'), true);
     expect(PasswordValidator.validate('password123'), true);
     expect(PhoneValidator.validate('+1234567890'), true);
   });
   ```

2. **Update Tests with Code**
   ```dart
   // When adding new feature
   class User {
     final String id;
     final String name;
     final String email; // New field
     
     User({
       required this.id,
       required this.name,
       required this.email, // Update constructor
     });
   }

   // Update related tests
   test('should create user with email', () {
     final user = User(
       id: '123',
       name: 'John',
       email: 'john@example.com', // Add email in tests
     );
     expect(user.email, 'john@example.com');
   });
   ```

## Next Steps

1. Review the [ARCHITECTURE_PATTERNS](ARCHITECTURE_PATTERNS.md) guide
2. Check the [CODE_STYLE](CODE_STYLE.md) guide
3. Read the [DEPENDENCY_MANAGEMENT](DEPENDENCY_MANAGEMENT.md) guide
