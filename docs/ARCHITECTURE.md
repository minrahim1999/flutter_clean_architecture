# Architecture Overview

This project follows Clean Architecture principles to create a scalable, maintainable, and testable codebase.

## Clean Architecture Layers

### 1. Domain Layer (Core Business Logic)

The innermost layer, containing:
- Business logic
- Entity models
- Repository interfaces
- Use cases

Key characteristics:
- No dependencies on outer layers
- Pure Dart code (no Flutter)
- Highly testable

### 2. Data Layer (Implementation)

Implements repository interfaces from the domain layer:
- Remote data sources (API)
- Local data sources (Database)
- Data models (DTOs)
- Repository implementations

Responsibilities:
- Data fetching and caching
- Error handling
- Data transformation

### 3. Presentation Layer (UI)

The outermost layer containing:
- Pages/Screens
- Widgets
- BLoC (Business Logic Component)
- UI models

Features:
- State management with flutter_bloc
- Dependency injection with get_it
- Navigation using go_router

## Dependency Flow

```
UI -> Presentation -> Domain <- Data
```

Dependencies point inward, with the domain layer having no dependencies on outer layers.

## Feature Structure

Each feature follows the same structure:

```
feature_name/
├── data/
│   ├── datasources/
│   │   ├── remote/
│   │   └── local/
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

## Testing Strategy

1. Unit Tests
   - Use cases
   - Repositories
   - BLoCs
   - Models

2. Widget Tests
   - Individual widgets
   - Screen widgets
   - Navigation

3. Integration Tests
   - Feature flows
   - Cross-feature interactions

## Dependency Injection

Uses get_it for service location:
- Singleton services
- Factory providers
- Lazy singletons
- Module registration

## Error Handling

Unified error handling approach:
1. Custom exceptions
2. Error models
3. UI error states
4. Error boundaries

## Navigation

Implements go_router for:
- Deep linking
- Nested navigation
- Route guards
- Path parameters
