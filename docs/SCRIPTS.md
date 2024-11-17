# Development Scripts Guide

This document provides detailed information about the development scripts available in this project.

## Feature Generation Script

### Usage
```bash
dart tools/scripts/create_feature.dart <feature_name>
```

Example:
```bash
dart tools/scripts/create_feature.dart user_profile
```

### What it does
The feature generation script creates a complete feature structure following Clean Architecture principles. It:

1. Creates all necessary directories:
   - `data/datasources`
   - `data/models`
   - `data/repositories`
   - `domain/entities`
   - `domain/repositories`
   - `domain/usecases`
   - `presentation/bloc`
   - `presentation/pages`
   - `presentation/widgets`

2. Creates corresponding test directories
3. Generates boilerplate code from templates
4. Updates necessary app configuration files:
   - `app.dart` (adds BLoC providers)
   - `app_router.dart` (adds routes)
   - `injection_container.dart` (adds dependencies)

### Requirements
- Feature name must be in snake_case format
- Templates must exist in the `tools/templates` directory

## Build Script

### Usage
```bash
dart tools/scripts/build.dart [platform]
```

Supported platforms:
- `apk` - Android APK
- `ios` - iOS build
- `web` - Web build
- `windows` - Windows build
- `macos` - macOS build
- `linux` - Linux build

## Run Script

### Usage
```bash
dart tools/scripts/run.dart [options]
```

Options:
- `--profile` - Run in profile mode
- `--release` - Run in release mode
- Default is debug mode

## Test Script

### Usage
```bash
dart tools/scripts/test.dart [options]
```

Options:
- `--coverage` - Generate coverage report
- `--watch` - Watch for changes and rerun tests
- `--update-goldens` - Update golden files

## Project Rename Script

### Usage
```bash
dart tools/scripts/rename_project.dart <new_name>
```

Example:
```bash
dart tools/scripts/rename_project.dart my_awesome_app
```

This script:
1. Updates pubspec.yaml
2. Renames Android/iOS bundle identifiers
3. Updates relevant configuration files
4. Maintains git history
