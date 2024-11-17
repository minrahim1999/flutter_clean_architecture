# Feature Template

This template follows Clean Architecture principles and provides a standard structure for implementing new features.

## Structure

```
feature_template/
├── domain/
│   ├── entities/
│   │   └── feature_entity.dart
│   ├── repositories/
│   │   └── feature_repository.dart
│   └── usecases/
│       └── get_features_usecase.dart
├── data/
│   ├── models/
│   │   └── feature_model.dart
│   ├── datasources/
│   │   ├── feature_remote_data_source.dart
│   │   └── feature_local_data_source.dart
│   └── repositories/
│       └── feature_repository_impl.dart
└── presentation/
    ├── bloc/
    │   └── feature_bloc.dart
    ├── pages/
    │   └── feature_page.dart
    └── widgets/
        ├── feature_list.dart
        ├── feature_list_item.dart
        ├── feature_loading.dart
        └── feature_error.dart
```

## Usage

1. Copy the `feature_template` directory
2. Rename all occurrences of "feature" to your feature name
3. Modify the entity and model according to your needs
4. Implement the data sources
5. Add your feature-specific UI components

## Components

### Domain Layer

- **Entities**: Core business objects
- **Repositories**: Abstract definition of data operations
- **Use Cases**: Business logic operations

### Data Layer

- **Models**: Data objects that implement entities
- **Data Sources**: 
  - Remote: API calls
  - Local: Database operations
- **Repository Implementation**: Concrete implementation of repositories

### Presentation Layer

- **BLoC**: State management
- **Pages**: Screen layouts
- **Widgets**: Reusable UI components

## Features

- Clean Architecture separation
- BLoC state management
- Error handling
- Loading states
- Pagination support
- Pull-to-refresh
- Offline support
- Material 3 design
- Theme support

## Dependencies

```yaml
dependencies:
  flutter_bloc: State management
  equatable: Value comparison
  dartz: Functional programming
  sembast: Local storage
  dio: HTTP client
```

## Example Usage

```dart
// Register dependencies
void initFeature() {
  final getIt = GetIt.instance;
  
  // Data sources
  getIt.registerLazySingleton<FeatureRemoteDataSource>(
    () => FeatureRemoteDataSourceImpl(
      apiService: getIt(),
    ),
  );
  
  getIt.registerLazySingleton<FeatureLocalDataSource>(
    () => FeatureLocalDataSourceImpl(
      database: getIt(),
    ),
  );
  
  // Repository
  getIt.registerLazySingleton<FeatureRepository>(
    () => FeatureRepositoryImpl(
      remoteDataSource: getIt(),
      localDataSource: getIt(),
      networkInfo: getIt(),
    ),
  );
  
  // Use cases
  getIt.registerLazySingleton(
    () => GetFeaturesUseCase(getIt()),
  );
  
  // BLoC
  getIt.registerFactory(
    () => FeatureBloc(
      getFeaturesUseCase: getIt(),
    ),
  );
}

// Use in app
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetIt.I<FeatureBloc>()
        ..add(const GetFeaturesEvent()),
      child: const FeaturePage(),
    );
  }
}
```

## Best Practices

1. **Error Handling**
   - Use Either type for error handling
   - Implement proper error UI
   - Cache errors for offline support

2. **State Management**
   - Keep states immutable
   - Use copyWith for state updates
   - Handle loading and error states

3. **Testing**
   - Write unit tests for use cases
   - Test BLoC state changes
   - Mock external dependencies

4. **UI/UX**
   - Show loading indicators
   - Implement error retry
   - Support pull-to-refresh
   - Add pagination

5. **Performance**
   - Cache network responses
   - Implement proper pagination
   - Use const constructors
   - Minimize rebuilds

## Customization

1. **Entity**: Add your feature-specific fields
```dart
class YourEntity extends Equatable {
  final String id;
  final String name;
  // Add your fields
}
```

2. **Repository**: Add feature-specific methods
```dart
abstract class YourRepository {
  Future<Either<Failure, List<YourEntity>>> getItems();
  // Add your methods
}
```

3. **BLoC**: Add feature-specific events and states
```dart
abstract class YourEvent extends Equatable {
  // Add your events
}

abstract class YourState extends Equatable {
  // Add your states
}
```

4. **UI**: Customize widgets
```dart
class YourListItem extends StatelessWidget {
  // Customize UI
}
```

## Testing

1. **Unit Tests**
```dart
void main() {
  group('GetFeaturesUseCase', () {
    test('should return features when repository succeeds', () async {
      // Write your tests
    });
  });
}
```

2. **BLoC Tests**
```dart
void main() {
  group('FeatureBloc', () {
    blocTest<FeatureBloc, FeatureState>(
      'emits [Loading, Loaded] when GetFeaturesEvent is added',
      // Write your tests
    );
  });
}
```

## Common Issues

1. **Network Errors**
   - Implement proper error handling
   - Show user-friendly error messages
   - Add retry mechanism

2. **State Management**
   - Handle edge cases
   - Manage side effects
   - Clean up resources

3. **Performance**
   - Optimize list rendering
   - Implement proper caching
   - Handle large datasets

## Contributing

1. Follow the template structure
2. Maintain clean architecture principles
3. Add proper documentation
4. Include tests
5. Follow code style guidelines
