# CODE STYLE

This document outlines our coding standards and style guidelines for the Flutter project.

## Table of Contents
1. [Dart Style Guide](#dart-style-guide)
2. [Flutter Style Guide](#flutter-style-guide)
3. [Project Conventions](#project-conventions)
4. [Documentation Style](#documentation-style)

## Dart Style Guide

### 1. Naming Conventions

```dart
// Classes and Enums - UpperCamelCase
class UserRepository {}
enum AuthenticationStatus {}

// Variables, Methods, Parameters - lowerCamelCase
final userName = 'John';
void getUserData() {}

// Constants - lowerCamelCase
const int maxLoginAttempts = 3;

// Private Members - _prefix
class User {
  final String _id;
  void _initialize() {}
}

// Type Parameters - Single uppercase letter or UpperCamelCase
class Cache<T> {}
class ApiResponse<ResponseType> {}
```

### 2. File Organization

```dart
// 1. Imports (organized by type)
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/entities/user.dart';
import '../data/models/user_model.dart';

// 2. Part declarations
part 'user_event.dart';
part 'user_state.dart';

// 3. Type declarations (classes, enums, etc.)
class UserBloc extends Bloc<UserEvent, UserState> {
  // Implementation
}
```

### 3. Code Layout

```dart
// 1. Good: Consistent formatting
class User {
  final String id;
  final String name;

  const User({
    required this.id,
    required this.name,
  });

  User copyWith({
    String? id,
    String? name,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }
}

// 2. Bad: Inconsistent formatting
class User{
  final String id;final String name;
  const User({required this.id,required this.name});
  User copyWith({String? id,String? name}){
    return User(id:id??this.id,name:name??this.name);
  }
}
```

## Flutter Style Guide

### 1. Widget Organization

```dart
class UserProfileScreen extends StatelessWidget {
  // 1. Static fields/constants
  static const routeName = '/profile';

  // 2. Instance fields
  final String userId;

  // 3. Constructors
  const UserProfileScreen({
    super.key,
    required this.userId,
  });

  // 4. Build method
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  // 5. Widget methods
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Profile'),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        return switch (state) {
          UserLoading() => const LoadingIndicator(),
          UserLoaded() => UserContent(user: state.user),
          UserError() => ErrorView(message: state.message),
          _ => const SizedBox(),
        };
      },
    );
  }
}
```

### 2. State Management

```dart
// 1. Events - Descriptive and specific
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

// 2. States - Clear and immutable
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final User user;

  const AuthSuccess(this.user);

  @override
  List<Object?> get props => [user];
}
```

### 3. UI Components

```dart
// 1. Reusable components
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const CircularProgressIndicator()
          : Text(text),
    );
  }
}

// 2. Theme usage
class ThemedText extends StatelessWidget {
  final String text;

  const ThemedText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyLarge,
    );
  }
}
```

## Project Conventions

### 1. Feature Organization

```
feature/
├── data/
│   ├── datasources/
│   │   ├── remote_data_source.dart
│   │   └── local_data_source.dart
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

### 2. Resource Organization

```dart
// 1. Assets
class Assets {
  static const String logo = 'assets/images/logo.png';
  static const String icon = 'assets/icons/app_icon.png';
}

// 2. Strings
class Strings {
  static const String appName = 'My App';
  static const String welcome = 'Welcome back!';
}

// 3. Dimensions
class Dimensions {
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
}
```

## Documentation Style

### 1. Class Documentation

```dart
/// A service that handles user authentication.
///
/// This service provides methods to:
/// * Sign in users
/// * Sign out users
/// * Check authentication status
/// * Manage user sessions
class AuthenticationService {
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

### 2. Method Documentation

```dart
/// Fetches user data from the remote server.
///
/// Parameters:
/// - [id]: The unique identifier of the user
/// - [includeDetails]: Whether to include additional user details
///
/// Returns a [User] object if successful.
/// Throws [ApiException] if the request fails.
Future<User> getUser(
  String id, {
  bool includeDetails = false,
}) async {
  // Implementation
}
```

### 3. Variable Documentation

```dart
/// The maximum number of login attempts before lockout.
static const int maxLoginAttempts = 3;

/// The current authentication state of the user.
///
/// This is updated whenever the user's authentication status changes.
final ValueNotifier<AuthState> authState = ValueNotifier(AuthState.initial);
```

## Best Practices

1. **Code Organization**
   - Keep files focused and small
   - Group related functionality
   - Use meaningful names
   - Follow consistent patterns

2. **Code Quality**
   - Use static analysis
   - Write clear comments
   - Keep methods small
   - Follow DRY principle

3. **Performance**
   - Use const constructors
   - Implement proper caching
   - Optimize build methods
   - Profile regularly

4. **Testing**
   - Write testable code
   - Follow test naming conventions
   - Use meaningful assertions
   - Mock external dependencies

## Next Steps

1. Review the [ARCHITECTURE_PATTERNS](ARCHITECTURE_PATTERNS.md) guide
2. Check the [TEST_CONVENTIONS](TEST_CONVENTIONS.md) guide
3. Read the [DEPENDENCY_MANAGEMENT](DEPENDENCY_MANAGEMENT.md) guide
