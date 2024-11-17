# Style Guide

This document outlines the coding conventions and best practices for this project.

## Dart Style Guide

### Naming Conventions

1. **Classes and Types**
   - PascalCase
   - Clear and descriptive
   ```dart
   class UserRepository {}
   class AuthenticationBloc {}
   ```

2. **Variables and Functions**
   - camelCase
   - Verb for functions
   - Noun for variables
   ```dart
   void getUserProfile() {}
   final String userName;
   ```

3. **Constants**
   - SCREAMING_SNAKE_CASE
   ```dart
   const int MAX_RETRY_ATTEMPTS = 3;
   ```

4. **Private Members**
   - Prefix with underscore
   ```dart
   final _authService = AuthService();
   void _handleError() {}
   ```

### File Organization

1. **Directory Structure**
   ```
   lib/
   ├── core/
   │   ├── constants/
   │   ├── errors/
   │   └── utils/
   └── features/
       └── feature_name/
           ├── data/
           ├── domain/
           └── presentation/
   ```

2. **File Naming**
   - snake_case
   - Descriptive and specific
   ```
   user_repository.dart
   authentication_bloc.dart
   home_page.dart
   ```

### Code Organization

1. **Import Ordering**
   ```dart
   // Dart imports
   import 'dart:async';
   import 'dart:io';

   // Package imports
   import 'package:flutter/material.dart';
   import 'package:flutter_bloc/flutter_bloc.dart';

   // Project imports
   import 'package:my_app/core/utils.dart';
   ```

2. **Class Organization**
   ```dart
   class MyWidget extends StatelessWidget {
     // Constants
     static const double _padding = 8.0;

     // Fields
     final String title;

     // Constructor
     const MyWidget({Key? key, required this.title}) : super(key: key);

     // Methods
     void _handleTap() {}

     // Build method
     @override
     Widget build(BuildContext context) {}
   }
   ```

## Flutter Best Practices

### Widget Structure

1. **Composition Over Inheritance**
   ```dart
   // Good
   class MyWidget extends StatelessWidget {
     final CustomWidget child;
     // ...
   }

   // Avoid
   class MyWidget extends CustomWidget {
     // ...
   }
   ```

2. **Extract Reusable Widgets**
   ```dart
   // Good
   class UserListItem extends StatelessWidget {
     // ...
   }

   class UserList extends StatelessWidget {
     @override
     Widget build(BuildContext context) {
       return ListView.builder(
         itemBuilder: (context, index) => UserListItem(),
       );
     }
   }
   ```

### State Management

1. **BLoC Pattern**
   ```dart
   // Events
   abstract class AuthEvent {}
   class LoginRequested extends AuthEvent {}

   // States
   abstract class AuthState {}
   class AuthInitial extends AuthState {}

   // BLoC
   class AuthBloc extends Bloc<AuthEvent, AuthState> {
     AuthBloc() : super(AuthInitial());
   }
   ```

2. **Repository Pattern**
   ```dart
   abstract class UserRepository {
     Future<User> getUser(String id);
   }

   class UserRepositoryImpl implements UserRepository {
     @override
     Future<User> getUser(String id) async {
       // Implementation
     }
   }
   ```

### Error Handling

1. **Custom Exceptions**
   ```dart
   class NetworkException implements Exception {
     final String message;
     NetworkException(this.message);
   }
   ```

2. **Error Boundaries**
   ```dart
   class ErrorBoundary extends StatelessWidget {
     final Widget child;
     
     @override
     Widget build(BuildContext context) {
       return ErrorWidget.builder = (FlutterErrorDetails details) {
         return ErrorDisplay(details: details);
       };
     }
   }
   ```

### Testing

1. **Unit Tests**
   ```dart
   void main() {
     group('UserBloc', () {
       late UserBloc userBloc;
       
       setUp(() {
         userBloc = UserBloc();
       });

       test('initial state is correct', () {
         expect(userBloc.state, UserInitial());
       });
     });
   }
   ```

2. **Widget Tests**
   ```dart
   void main() {
     testWidgets('MyWidget displays title', (WidgetTester tester) async {
       await tester.pumpWidget(MyWidget(title: 'Test'));
       expect(find.text('Test'), findsOneWidget);
     });
   }
   ```

### Performance

1. **const Constructors**
   ```dart
   // Good
   const MyWidget({Key? key}) : super(key: key);
   ```

2. **ListView.builder for Long Lists**
   ```dart
   ListView.builder(
     itemCount: items.length,
     itemBuilder: (context, index) => ItemWidget(item: items[index]),
   )
   ```

3. **Avoid Unnecessary Rebuilds**
   ```dart
   // Good
   final padding = const EdgeInsets.all(8.0);
   
   // Avoid
   EdgeInsets.all(8.0)
   ```
