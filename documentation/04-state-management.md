# State Management Guide

This guide explains our approach to state management using BLoC (Business Logic Component) pattern in Flutter.

## Table of Contents
1. [BLoC Pattern](#bloc-pattern)
2. [State Handling](#state-handling)
3. [Event Processing](#event-processing)
4. [Integration with UI](#integration-with-ui)
5. [Best Practices](#best-practices)

## BLoC Pattern

### 1. Basic Structure

```dart
// Events
abstract class FeatureEvent extends Equatable {
  const FeatureEvent();

  @override
  List<Object?> get props => [];
}

// States
abstract class FeatureState extends Equatable {
  const FeatureState();

  @override
  List<Object?> get props => [];
}

// BLoC
class FeatureBloc extends Bloc<FeatureEvent, FeatureState> {
  final FeatureUseCase useCase;

  FeatureBloc({required this.useCase}) : super(FeatureInitial()) {
    on<LoadFeature>(_onLoadFeature);
    on<UpdateFeature>(_onUpdateFeature);
  }
}
```

### 2. Event Handling

```dart
// Events
class LoadFeature extends FeatureEvent {
  final String id;
  const LoadFeature(this.id);

  @override
  List<Object?> get props => [id];
}

class UpdateFeature extends FeatureEvent {
  final Feature feature;
  const UpdateFeature(this.feature);

  @override
  List<Object?> get props => [feature];
}

// BLoC Implementation
Future<void> _onLoadFeature(
  LoadFeature event,
  Emitter<FeatureState> emit,
) async {
  emit(FeatureLoading());
  
  final result = await useCase(event.id);
  result.fold(
    (failure) => emit(FeatureError(failure.message)),
    (feature) => emit(FeatureLoaded(feature)),
  );
}
```

## State Handling

### 1. State Classes

```dart
// Base State
abstract class FeatureState extends Equatable {
  const FeatureState();

  @override
  List<Object?> get props => [];
}

// Concrete States
class FeatureInitial extends FeatureState {}

class FeatureLoading extends FeatureState {}

class FeatureLoaded extends FeatureState {
  final Feature feature;
  const FeatureLoaded(this.feature);

  @override
  List<Object?> get props => [feature];
}

class FeatureError extends FeatureState {
  final String message;
  const FeatureError(this.message);

  @override
  List<Object?> get props => [message];
}
```

### 2. State Transitions

```dart
class FeatureBloc extends Bloc<FeatureEvent, FeatureState> {
  @override
  void onTransition(Transition<FeatureEvent, FeatureState> transition) {
    super.onTransition(transition);
    log('Event: ${transition.event}');
    log('Current State: ${transition.currentState}');
    log('Next State: ${transition.nextState}');
  }
}
```

## Event Processing

### 1. Event Handlers

```dart
class FeatureBloc extends Bloc<FeatureEvent, FeatureState> {
  FeatureBloc({required this.useCase}) : super(FeatureInitial()) {
    on<LoadFeature>(_onLoadFeature);
    on<UpdateFeature>(_onUpdateFeature);
    on<DeleteFeature>(_onDeleteFeature);
  }

  Future<void> _onLoadFeature(
    LoadFeature event,
    Emitter<FeatureState> emit,
  ) async {
    await _handleApiCall(
      () => useCase.getFeature(event.id),
      emit,
    );
  }

  Future<void> _handleApiCall<T>(
    Future<Either<Failure, T>> Function() call,
    Emitter<FeatureState> emit,
  ) async {
    emit(FeatureLoading());
    
    final result = await call();
    result.fold(
      (failure) => emit(FeatureError(failure.message)),
      (data) => emit(FeatureLoaded(data as Feature)),
    );
  }
}
```

### 2. Error Handling

```dart
class FeatureBloc extends Bloc<FeatureEvent, FeatureState> {
  @override
  void onError(Object error, StackTrace stackTrace) {
    log('Error in FeatureBloc: $error');
    log('StackTrace: $stackTrace');
    super.onError(error, stackTrace);
  }

  Future<void> _handleError(
    Object error,
    Emitter<FeatureState> emit,
  ) async {
    if (error is NetworkException) {
      emit(const FeatureError('Network error occurred'));
    } else if (error is CacheException) {
      emit(const FeatureError('Cache error occurred'));
    } else {
      emit(FeatureError(error.toString()));
    }
  }
}
```

## Integration with UI

### 1. BLoC Provider

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<FeatureBloc>(
          create: (context) => sl<FeatureBloc>(),
        ),
        BlocProvider<ThemeBloc>(
          create: (context) => sl<ThemeBloc>(),
        ),
      ],
      child: const AppView(),
    );
  }
}
```

### 2. BLoC Consumer

```dart
class FeatureView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FeatureBloc, FeatureState>(
      listener: (context, state) {
        if (state is FeatureError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        return switch (state) {
          FeatureLoading() => const LoadingIndicator(),
          FeatureLoaded() => FeatureContent(feature: state.feature),
          FeatureError() => ErrorView(message: state.message),
          _ => const SizedBox(),
        };
      },
    );
  }
}
```

### 3. BLoC Selector

```dart
class FeatureStatusWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocSelector<FeatureBloc, FeatureState, bool>(
      selector: (state) => state is FeatureLoading,
      builder: (context, isLoading) {
        return isLoading
            ? const CircularProgressIndicator()
            : const SizedBox();
      },
    );
  }
}
```

## Best Practices

### 1. BLoC Organization

```dart
// 1. Keep BLoCs focused
class FeatureBloc extends Bloc<FeatureEvent, FeatureState> {
  // One responsibility per BLoC
}

// 2. Use sealed classes for events and states
sealed class FeatureEvent {}
sealed class FeatureState {}

// 3. Implement proper equatable
class LoadFeature extends FeatureEvent {
  final String id;
  const LoadFeature(this.id);

  @override
  List<Object?> get props => [id];
}
```

### 2. Performance Optimization

```dart
// 1. Avoid unnecessary rebuilds
class OptimizedWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocSelector<FeatureBloc, FeatureState, Feature?>(
      selector: (state) => state is FeatureLoaded ? state.feature : null,
      builder: (context, feature) {
        if (feature == null) return const SizedBox();
        return FeatureWidget(feature: feature);
      },
    );
  }
}

// 2. Cancel subscriptions
@override
Future<void> close() {
  _subscription?.cancel();
  return super.close();
}
```

### 3. Testing

```dart
void main() {
  group('FeatureBloc', () {
    late FeatureBloc bloc;
    late MockFeatureUseCase mockUseCase;

    setUp(() {
      mockUseCase = MockFeatureUseCase();
      bloc = FeatureBloc(useCase: mockUseCase);
    });

    blocTest<FeatureBloc, FeatureState>(
      'emits [Loading, Loaded] when successful',
      build: () => bloc,
      act: (bloc) => bloc.add(const LoadFeature('123')),
      expect: () => [
        isA<FeatureLoading>(),
        isA<FeatureLoaded>(),
      ],
    );
  });
}
```

## Next Steps

1. Review the [Testing Guide](05-testing.md)
2. Check the [Deployment Guide](06-deployment.md)
3. Read the [Flavor Configuration](07-flavor-configuration.md)

---

Next: [Testing Guide](05-testing.md)
