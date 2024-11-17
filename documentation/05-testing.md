# Testing Guide

This guide explains our testing strategy and implementation for the Flutter application.

## Table of Contents
1. [Testing Strategy](#testing-strategy)
2. [Unit Tests](#unit-tests)
3. [Widget Tests](#widget-tests)
4. [Integration Tests](#integration-tests)
5. [Test Coverage](#test-coverage)

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

### 1. Use Case Tests

```dart
void main() {
  group('GetFeatureUseCase', () {
    late GetFeatureUseCase useCase;
    late MockFeatureRepository repository;

    setUp(() {
      repository = MockFeatureRepository();
      useCase = GetFeatureUseCase(repository);
    });

    test('should get feature from repository', () async {
      // Arrange
      const id = '123';
      final feature = Feature(id: id, name: 'Test');
      when(() => repository.getFeature(id))
          .thenAnswer((_) async => Right(feature));

      // Act
      final result = await useCase(id);

      // Assert
      expect(result, Right(feature));
      verify(() => repository.getFeature(id)).called(1);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      const id = '123';
      when(() => repository.getFeature(id))
          .thenAnswer((_) async => Left(ServerFailure()));

      // Act
      final result = await useCase(id);

      // Assert
      expect(result, Left(ServerFailure()));
      verify(() => repository.getFeature(id)).called(1);
    });
  });
}
```

### 2. Repository Tests

```dart
void main() {
  group('FeatureRepositoryImpl', () {
    late FeatureRepositoryImpl repository;
    late MockRemoteDataSource remoteDataSource;
    late MockLocalDataSource localDataSource;
    late MockNetworkInfo networkInfo;

    setUp(() {
      remoteDataSource = MockRemoteDataSource();
      localDataSource = MockLocalDataSource();
      networkInfo = MockNetworkInfo();
      repository = FeatureRepositoryImpl(
        remoteDataSource: remoteDataSource,
        localDataSource: localDataSource,
        networkInfo: networkInfo,
      );
    });

    group('getFeature', () {
      test('should return remote data when online', () async {
        // Arrange
        const id = '123';
        final feature = FeatureModel(id: id, name: 'Test');
        when(() => networkInfo.isConnected).thenAnswer((_) async => true);
        when(() => remoteDataSource.getFeature(id))
            .thenAnswer((_) async => feature);

        // Act
        final result = await repository.getFeature(id);

        // Assert
        expect(result, Right(feature));
        verify(() => remoteDataSource.getFeature(id)).called(1);
      });

      test('should return cached data when offline', () async {
        // Arrange
        const id = '123';
        final feature = FeatureModel(id: id, name: 'Test');
        when(() => networkInfo.isConnected).thenAnswer((_) async => false);
        when(() => localDataSource.getFeature(id))
            .thenAnswer((_) async => feature);

        // Act
        final result = await repository.getFeature(id);

        // Assert
        expect(result, Right(feature));
        verify(() => localDataSource.getFeature(id)).called(1);
        verifyNever(() => remoteDataSource.getFeature(id));
      });
    });
  });
}
```

### 3. BLoC Tests

```dart
void main() {
  group('FeatureBloc', () {
    late FeatureBloc bloc;
    late MockGetFeature mockGetFeature;
    late MockUpdateFeature mockUpdateFeature;

    setUp(() {
      mockGetFeature = MockGetFeature();
      mockUpdateFeature = MockUpdateFeature();
      bloc = FeatureBloc(
        getFeature: mockGetFeature,
        updateFeature: mockUpdateFeature,
      );
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is FeatureInitial', () {
      expect(bloc.state, equals(FeatureInitial()));
    });

    blocTest<FeatureBloc, FeatureState>(
      'emits [Loading, Loaded] when LoadFeature is added',
      build: () {
        when(() => mockGetFeature(any()))
            .thenAnswer((_) async => Right(testFeature));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadFeature('123')),
      expect: () => [
        FeatureLoading(),
        FeatureLoaded(testFeature),
      ],
      verify: (_) {
        verify(() => mockGetFeature('123')).called(1);
      },
    );
  });
}
```

## Widget Tests

### 1. Widget Testing

```dart
void main() {
  group('FeatureWidget', () {
    testWidgets('displays feature data correctly',
        (WidgetTester tester) async {
      // Arrange
      const feature = Feature(id: '123', name: 'Test Feature');

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: FeatureWidget(feature: feature),
        ),
      );

      // Assert
      expect(find.text('Test Feature'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('handles user interaction',
        (WidgetTester tester) async {
      // Arrange
      const feature = Feature(id: '123', name: 'Test Feature');
      final onPressed = MockCallback();

      await tester.pumpWidget(
        MaterialApp(
          home: FeatureWidget(
            feature: feature,
            onPressed: onPressed,
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Assert
      verify(onPressed).called(1);
    });
  });
}
```

### 2. Screen Testing

```dart
void main() {
  group('FeatureScreen', () {
    late MockFeatureBloc mockBloc;

    setUp(() {
      mockBloc = MockFeatureBloc();
    });

    testWidgets('displays loading state correctly',
        (WidgetTester tester) async {
      // Arrange
      when(() => mockBloc.state).thenReturn(FeatureLoading());

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<FeatureBloc>.value(
            value: mockBloc,
            child: const FeatureScreen(),
          ),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays error state correctly',
        (WidgetTester tester) async {
      // Arrange
      const errorMessage = 'Error occurred';
      when(() => mockBloc.state)
          .thenReturn(const FeatureError(errorMessage));

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<FeatureBloc>.value(
            value: mockBloc,
            child: const FeatureScreen(),
          ),
        ),
      );

      // Assert
      expect(find.text(errorMessage), findsOneWidget);
      expect(find.byType(RetryButton), findsOneWidget);
    });
  });
}
```

## Integration Tests

### 1. Feature Flow Tests

```dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-End Test', () {
    testWidgets('complete feature flow', (tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to feature
      await tester.tap(find.byKey(const Key('feature_button')));
      await tester.pumpAndSettle();

      // Verify initial state
      expect(find.text('Feature Screen'), findsOneWidget);

      // Perform actions
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Verify results
      expect(find.text('Success'), findsOneWidget);
    });
  });
}
```

### 2. Navigation Tests

```dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Navigation Test', () {
    testWidgets('navigation flow', (tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      // Test navigation
      await tester.tap(find.byKey(const Key('first_screen')));
      await tester.pumpAndSettle();
      expect(find.text('First Screen'), findsOneWidget);

      await tester.tap(find.byKey(const Key('second_screen')));
      await tester.pumpAndSettle();
      expect(find.text('Second Screen'), findsOneWidget);

      // Test back navigation
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('First Screen'), findsOneWidget);
    });
  });
}
```

## Test Coverage

### 1. Running Coverage

```bash
# Generate coverage report
flutter test --coverage

# Generate HTML report
genhtml coverage/lcov.info -o coverage/html

# Open coverage report
open coverage/html/index.html
```

### 2. Coverage Rules

1. **Minimum Coverage Requirements**
   - Unit Tests: 90%
   - Widget Tests: 80%
   - Integration Tests: 70%

2. **Critical Paths**
   - Authentication: 100%
   - Data persistence: 100%
   - Network operations: 100%

## Best Practices

1. **Test Organization**
   - Group related tests
   - Use descriptive names
   - Follow AAA pattern
   - Keep tests focused

2. **Mocking**
   - Mock external dependencies
   - Use mockito effectively
   - Verify interactions
   - Handle async operations

3. **Maintenance**
   - Update tests with code
   - Remove obsolete tests
   - Keep tests simple
   - Document complex tests

## Next Steps

1. Check the [Deployment Guide](06-deployment.md)
2. Review the [Flavor Configuration](07-flavor-configuration.md)
3. Read the [Plugin Development](08-plugin-development.md)

---

Next: [Deployment Guide](06-deployment.md)
