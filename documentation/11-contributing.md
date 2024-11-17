# Contributing Guide

Welcome to our Flutter project! This guide will help you understand how to contribute effectively to the project.

## Table of Contents
1. [Getting Started](#getting-started)
2. [Development Process](#development-process)
3. [Code Style](#code-style)
4. [Testing Guidelines](#testing-guidelines)
5. [Pull Request Process](#pull-request-process)
6. [Documentation](#documentation)

## Getting Started

### 1. Setup Development Environment

1. **Install Required Tools**
```bash
# Install Flutter
flutter pub get

# Install dependencies
flutter pub get

# Run code generation
flutter pub run build_runner build --delete-conflicting-outputs
```

2. **Configure IDE**
   - Install Flutter and Dart plugins
   - Configure code style settings
   - Setup recommended extensions

### 2. Project Structure

```
lib/
├── core/                 # Core functionality
│   ├── bloc/            # Global BLoCs
│   ├── di/              # Dependency injection
│   ├── network/         # Network handling
│   └── utils/           # Utilities
├── features/            # Feature modules
│   └── feature_name/    # Individual feature
│       ├── data/        # Data layer
│       ├── domain/      # Domain layer
│       └── presentation/# UI layer
└── main.dart           # Application entry
```

## Development Process

### 1. Feature Development

1. **Create Feature Branch**
```bash
# Create and checkout feature branch
git checkout -b feature/feature-name
```

2. **Generate Feature Structure**
```bash
# Use feature generation script
dart tools/scripts/create_feature.dart feature_name
```

3. **Implement Feature**
```dart
// Follow Clean Architecture
// 1. Create Entity
class FeatureEntity extends Equatable {
  // Entity implementation
}

// 2. Create Repository Interface
abstract class FeatureRepository {
  // Repository methods
}

// 3. Implement Use Cases
class GetFeatureUseCase implements UseCase<FeatureEntity, NoParams> {
  // Use case implementation
}

// 4. Create BLoC
class FeatureBloc extends Bloc<FeatureEvent, FeatureState> {
  // BLoC implementation
}
```

### 2. Code Review Process

1. **Pre-Review Checklist**
   - Run tests
   - Format code
   - Update documentation
   - Check lint warnings

2. **Review Guidelines**
   - Check code style
   - Verify test coverage
   - Review documentation
   - Test functionality

## Code Style

### 1. Dart Style Guide

```dart
// 1. Class Organization
class MyClass {
  // 1. Static fields
  static const defaultValue = 0;

  // 2. Instance fields
  final String name;
  
  // 3. Constructors
  MyClass({required this.name});
  
  // 4. Static methods
  static MyClass create() => MyClass(name: 'default');
  
  // 5. Instance methods
  void doSomething() {
    // Method implementation
  }
}

// 2. Naming Conventions
class UserRepository {
  // Camel case for methods
  Future<User> getUserById(String id);
  
  // Private fields with underscore
  final UserApi _api;
}

// 3. File Organization
// feature/
// ├── data/
// │   ├── models/
// │   │   └── user_model.dart
// │   └── repositories/
// │       └── user_repository_impl.dart
// └── domain/
//     ├── entities/
//     │   └── user.dart
//     └── repositories/
//         └── user_repository.dart
```

### 2. Flutter Style Guide

```dart
// 1. Widget Organization
class MyWidget extends StatelessWidget {
  // 1. Constructor and fields
  const MyWidget({
    super.key,
    required this.title,
  });

  // 2. Fields
  final String title;

  // 3. Build method
  @override
  Widget build(BuildContext context) {
    return Container(
      // Widget implementation
    );
  }
}

// 2. Widget Best Practices
class ResponsiveWidget extends StatelessWidget {
  // Use const constructors
  const ResponsiveWidget({super.key});

  // Extract reusable widgets
  Widget _buildHeader() {
    return const Header();
  }

  // Use named parameters for clarity
  Widget _buildContent({
    required String title,
    required Widget child,
  }) {
    return Column(
      children: [
        Text(title),
        child,
      ],
    );
  }
}
```

## Testing Guidelines

### 1. Unit Tests

```dart
void main() {
  group('FeatureBloc', () {
    late FeatureBloc bloc;
    late MockRepository repository;

    setUp(() {
      repository = MockRepository();
      bloc = FeatureBloc(repository: repository);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is correct', () {
      expect(bloc.state, equals(FeatureInitial()));
    });

    blocTest<FeatureBloc, FeatureState>(
      'emits [Loading, Loaded] when successful',
      build: () => bloc,
      act: (bloc) => bloc.add(LoadFeature()),
      expect: () => [
        FeatureLoading(),
        FeatureLoaded(),
      ],
    );
  });
}
```

### 2. Widget Tests

```dart
void main() {
  group('MyWidget', () {
    testWidgets('renders correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MyWidget(),
        ),
      );

      expect(find.byType(MyWidget), findsOneWidget);
    });

    testWidgets('handles user interaction', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MyWidget(),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Clicked'), findsOneWidget);
    });
  });
}
```

## Pull Request Process

### 1. Creating a Pull Request

1. **Update Documentation**
   - Add feature documentation
   - Update API documentation
   - Update README if needed

2. **Run Quality Checks**
```bash
# Format code
flutter format .

# Run tests
flutter test

# Run static analysis
flutter analyze
```

3. **Create PR Description**
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Unit tests added/updated
- [ ] Widget tests added/updated
- [ ] Integration tests added/updated

## Screenshots
If applicable, add screenshots

## Checklist
- [ ] Code follows style guidelines
- [ ] Tests pass locally
- [ ] Documentation updated
- [ ] No new warnings
```

### 2. Review Process

1. **Code Review Checklist**
   - Code follows style guide
   - Tests are comprehensive
   - Documentation is complete
   - No unnecessary changes

2. **Reviewer Guidelines**
   - Be constructive
   - Focus on important issues
   - Suggest improvements
   - Check test coverage

## Documentation

### 1. Code Documentation

```dart
/// A service that handles user authentication.
///
/// This service provides methods to:
/// * Sign in users
/// * Sign out users
/// * Check authentication status
class AuthService {
  /// Signs in a user with email and password.
  ///
  /// Throws [AuthException] if:
  /// * Email is invalid
  /// * Password is incorrect
  /// * Network error occurs
  Future<User> signIn({
    required String email,
    required String password,
  }) async {
    // Implementation
  }
}
```

### 2. API Documentation

```dart
/// API client for the feature module.
class FeatureApi {
  /// Fetches feature data from the server.
  ///
  /// Parameters:
  /// - [id]: The unique identifier of the feature
  /// - [options]: Optional parameters for the request
  ///
  /// Returns a [FeatureModel] if successful.
  /// Throws [ApiException] if the request fails.
  Future<FeatureModel> getFeature(
    String id, {
    Map<String, dynamic>? options,
  }) async {
    // Implementation
  }
}
```

## Best Practices

1. **Code Quality**
   - Write clean, readable code
   - Follow SOLID principles
   - Use meaningful names
   - Keep methods small

2. **Testing**
   - Write tests first (TDD)
   - Cover edge cases
   - Mock dependencies
   - Test UI interactions

3. **Documentation**
   - Document public APIs
   - Add code comments
   - Update README
   - Include examples

4. **Version Control**
   - Write clear commit messages
   - Keep PRs focused
   - Rebase when needed
   - Use feature branches

## Community Guidelines

1. **Communication**
   - Be respectful
   - Stay professional
   - Help others
   - Share knowledge

2. **Issue Reporting**
   - Use issue templates
   - Provide clear steps
   - Include environment info
   - Add screenshots

## Next Steps

1. Check the [Future Features](12-future-features.md)
2. Review the [Troubleshooting Guide](13-troubleshooting.md)
3. Read the [Performance Guide](14-performance-guide.md)

---

Next: [Future Features](12-future-features.md)
