# Feature Development Guide

This guide explains how to create and implement new features in the application following our clean architecture principles.

## Feature Generation

Use our feature generation tool to create a new feature:

```bash
dart tools/scripts/create_feature.dart feature_name
```

This will create the following structure:

```
features/
└── feature_name/
    ├── data/
    │   ├── datasources/
    │   ├── models/
    │   └── repositories/
    ├── domain/
    │   ├── entities/
    │   ├── repositories/
    │   └── usecases/
    └── presentation/
        ├── bloc/
        ├── pages/
        └── widgets/
```

## Step-by-Step Feature Development

### 1. Define the Entity

```dart
// lib/features/feature_name/domain/entities/feature.dart

class Feature extends Equatable {
  final String id;
  final String name;
  final String description;

  const Feature({
    required this.id,
    required this.name,
    required this.description,
  });

  @override
  List<Object> get props => [id, name, description];
}
```

### 2. Create the Model

```dart
// lib/features/feature_name/data/models/feature_model.dart

class FeatureModel extends Feature {
  const FeatureModel({
    required String id,
    required String name,
    required String description,
  }) : super(
          id: id,
          name: name,
          description: description,
        );

  factory FeatureModel.fromJson(Map<String, dynamic> json) {
    return FeatureModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }
}
```

### 3. Define the Repository Interface

```dart
// lib/features/feature_name/domain/repositories/feature_repository.dart

abstract class FeatureRepository {
  Future<Either<Failure, List<Feature>>> getFeatures();
  Future<Either<Failure, Feature>> getFeatureById(String id);
  Future<Either<Failure, Feature>> createFeature(Feature feature);
  Future<Either<Failure, Feature>> updateFeature(Feature feature);
  Future<Either<Failure, bool>> deleteFeature(String id);
}
```

### 4. Implement Data Sources

```dart
// lib/features/feature_name/data/datasources/feature_remote_data_source.dart

abstract class FeatureRemoteDataSource {
  Future<List<FeatureModel>> getFeatures();
  Future<FeatureModel> getFeatureById(String id);
  Future<FeatureModel> createFeature(FeatureModel feature);
  Future<FeatureModel> updateFeature(FeatureModel feature);
  Future<bool> deleteFeature(String id);
}

class FeatureRemoteDataSourceImpl implements FeatureRemoteDataSource {
  final ApiService _apiService;

  FeatureRemoteDataSourceImpl({required ApiService apiService})
      : _apiService = apiService;

  @override
  Future<List<FeatureModel>> getFeatures() async {
    try {
      final response = await _apiService.get('/features');
      if (response.isSuccess && response.data != null) {
        final List<dynamic> items = response.data!['items'] as List;
        return items
            .map((item) => FeatureModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException(
          message: response.errorMessage ?? 'Failed to get features',
        );
      }
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
```

### 5. Implement the Repository

```dart
// lib/features/feature_name/data/repositories/feature_repository_impl.dart

class FeatureRepositoryImpl implements FeatureRepository {
  final FeatureRemoteDataSource remoteDataSource;
  final FeatureLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  FeatureRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Feature>>> getFeatures() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteFeatures = await remoteDataSource.getFeatures();
        await localDataSource.cacheFeatures(remoteFeatures);
        return Right(remoteFeatures);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      try {
        final localFeatures = await localDataSource.getFeatures();
        return Right(localFeatures);
      } on CacheException {
        return Left(CacheFailure());
      }
    }
  }
}
```

### 6. Create Use Cases

```dart
// lib/features/feature_name/domain/usecases/get_features.dart

class GetFeatures implements UseCase<List<Feature>, NoParams> {
  final FeatureRepository repository;

  GetFeatures(this.repository);

  @override
  Future<Either<Failure, List<Feature>>> call(NoParams params) {
    return repository.getFeatures();
  }
}
```

### 7. Implement the BLoC

```dart
// lib/features/feature_name/presentation/bloc/feature_bloc.dart

class FeatureBloc extends Bloc<FeatureEvent, FeatureState> {
  final GetFeatures getFeatures;
  final CreateFeature createFeature;
  final UpdateFeature updateFeature;
  final DeleteFeature deleteFeature;

  FeatureBloc({
    required this.getFeatures,
    required this.createFeature,
    required this.updateFeature,
    required this.deleteFeature,
  }) : super(FeatureInitial()) {
    on<GetFeaturesRequested>(_onGetFeaturesRequested);
    on<CreateFeatureRequested>(_onCreateFeatureRequested);
    on<UpdateFeatureRequested>(_onUpdateFeatureRequested);
    on<DeleteFeatureRequested>(_onDeleteFeatureRequested);
  }

  Future<void> _onGetFeaturesRequested(
    GetFeaturesRequested event,
    Emitter<FeatureState> emit,
  ) async {
    emit(FeaturesLoading());
    final result = await getFeatures(NoParams());
    result.fold(
      (failure) => emit(FeaturesError(message: failure.message)),
      (features) => emit(FeaturesLoaded(features: features)),
    );
  }
}
```

### 8. Create the UI

```dart
// lib/features/feature_name/presentation/pages/feature_page.dart

class FeaturePage extends StatelessWidget {
  const FeaturePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<FeatureBloc>()
        ..add(const GetFeaturesRequested()),
      child: BaseScreen(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Features'),
          ),
          body: BlocBuilder<FeatureBloc, FeatureState>(
            builder: (context, state) {
              return switch (state) {
                FeaturesLoading() => const Center(
                    child: CircularProgressIndicator(),
                  ),
                FeaturesLoaded() => FeatureList(
                    features: state.features,
                  ),
                FeaturesError() => Center(
                    child: Text(state.message),
                  ),
                _ => const SizedBox(),
              };
            },
          ),
        ),
      ),
    );
  }
}
```

### 9. Register Dependencies

```dart
// lib/core/di/injection_container.dart

void registerFeatureModule() {
  // BLoC
  sl.registerFactory(
    () => FeatureBloc(
      getFeatures: sl(),
      createFeature: sl(),
      updateFeature: sl(),
      deleteFeature: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetFeatures(sl()));
  sl.registerLazySingleton(() => CreateFeature(sl()));
  sl.registerLazySingleton(() => UpdateFeature(sl()));
  sl.registerLazySingleton(() => DeleteFeature(sl()));

  // Repository
  sl.registerLazySingleton<FeatureRepository>(
    () => FeatureRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data Sources
  sl.registerLazySingleton<FeatureRemoteDataSource>(
    () => FeatureRemoteDataSourceImpl(apiService: sl()),
  );
  sl.registerLazySingleton<FeatureLocalDataSource>(
    () => FeatureLocalDataSourceImpl(store: sl()),
  );
}
```

### 10. Add Feature Route

```dart
// lib/core/router/app_router.dart

final router = GoRouter(
  routes: [
    // ... other routes
    GoRoute(
      path: '/features',
      builder: (context, state) => const FeaturePage(),
    ),
  ],
);
```

## Testing the Feature

1. **Unit Tests**
```dart
void main() {
  group('FeatureBloc', () {
    late FeatureBloc bloc;
    late MockGetFeatures mockGetFeatures;

    setUp(() {
      mockGetFeatures = MockGetFeatures();
      bloc = FeatureBloc(getFeatures: mockGetFeatures);
    });

    test('initial state is FeatureInitial', () {
      expect(bloc.state, equals(FeatureInitial()));
    });

    blocTest<FeatureBloc, FeatureState>(
      'emits [FeaturesLoading, FeaturesLoaded] when successful',
      build: () {
        when(() => mockGetFeatures(any()))
            .thenAnswer((_) async => Right([testFeature]));
        return bloc;
      },
      act: (bloc) => bloc.add(const GetFeaturesRequested()),
      expect: () => [
        FeaturesLoading(),
        FeaturesLoaded(features: [testFeature]),
      ],
    );
  });
}
```

2. **Widget Tests**
```dart
void main() {
  group('FeaturePage', () {
    testWidgets('renders FeatureList when state is loaded',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: MockFeatureBloc(),
            child: const FeaturePage(),
          ),
        ),
      );

      expect(find.byType(FeatureList), findsOneWidget);
    });
  });
}
```

## Best Practices

1. **Follow Clean Architecture**
   - Keep layers separate
   - Dependencies point inward
   - Domain layer has no dependencies

2. **Use BLoC Pattern**
   - Keep business logic in BLoCs
   - Use events and states
   - Handle errors properly

3. **Write Tests**
   - Unit tests for logic
   - Widget tests for UI
   - Integration tests for flows

4. **Error Handling**
   - Use Either for results
   - Handle all edge cases
   - Provide meaningful messages

## Next Steps

1. Read the [State Management Guide](04-state-management.md)
2. Check the [Testing Guide](05-testing.md)
3. Review the [Deployment Guide](06-deployment.md)

---

Next: [State Management](04-state-management.md)
