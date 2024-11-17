# Flavor Configuration Guide

This guide explains how to work with different build flavors in the Flutter Clean Architecture project, specifically focusing on GMS (Google Mobile Services) and HMS (Huawei Mobile Services) implementations.

## Table of Contents
1. [Overview](#overview)
2. [Flavor Types](#flavor-types)
3. [Directory Structure](#directory-structure)
4. [Configuration](#configuration)
5. [Development](#development)
6. [Building](#building)
7. [Testing](#testing)

## Overview

The project supports multiple build flavors to handle different service implementations and distribution channels:
- Google Mobile Services (GMS) for Google Play Store
- Huawei Mobile Services (HMS) for Huawei AppGallery

## Flavor Types

### GMS (Google Mobile Services)
- Full Google services support
- Play Store distribution
- Google Maps, Firebase, and other Google services
- Default flavor for most markets

### HMS (Huawei Mobile Services)
- Full Huawei services support
- AppGallery distribution
- Huawei Maps, HMS Core, and other Huawei services
- Required for Huawei devices without GMS

## Directory Structure

```
android/
├── app/
│   └── src/
│       ├── gms/                 # GMS specific code
│       │   ├── kotlin/         # Kotlin/Java sources
│       │   └── res/           # Resources
│       ├── hms/                 # HMS specific code
│       │   ├── kotlin/         # Kotlin/Java sources
│       │   └── res/           # Resources
│       └── main/               # Common code
│           ├── kotlin/
│           └── res/

lib/
├── services/
│   ├── gms/                    # GMS service implementations
│   │   ├── maps_service.dart
│   │   └── push_service.dart
│   ├── hms/                    # HMS service implementations
│   │   ├── maps_service.dart
│   │   └── push_service.dart
│   └── interfaces/             # Service interfaces
│       ├── maps_service.dart
│       └── push_service.dart
```

## Configuration

### Android Configuration

1. **build.gradle**
```groovy
android {
    flavorDimensions "services"
    
    productFlavors {
        gms {
            dimension "services"
            applicationId "com.myapp.gms"
            resValue "string", "app_name", "My App GMS"
        }
        
        hms {
            dimension "services"
            applicationId "com.myapp.hms"
            resValue "string", "app_name", "My App HMS"
        }
    }
}

dependencies {
    // GMS dependencies
    gmsImplementation 'com.google.android.gms:play-services-base:18.2.0'
    gmsImplementation 'com.google.android.gms:play-services-maps:18.2.0'
    
    // HMS dependencies
    hmsImplementation 'com.huawei.hms:base:6.11.0.300'
    hmsImplementation 'com.huawei.hms:maps:6.11.1.301'
}
```

### Flutter Configuration

1. **Service Interface**
```dart
abstract class MapService {
  Future<void> initialize();
  Future<void> showMap(double lat, double lng);
}
```

2. **GMS Implementation**
```dart
class GMSMapService implements MapService {
  @override
  Future<void> initialize() async {
    // Initialize Google Maps
  }

  @override
  Future<void> showMap(double lat, double lng) async {
    // Show Google Maps
  }
}
```

3. **HMS Implementation**
```dart
class HMSMapService implements MapService {
  @override
  Future<void> initialize() async {
    // Initialize Huawei Maps
  }

  @override
  Future<void> showMap(double lat, double lng) async {
    // Show Huawei Maps
  }
}
```

## Development

### Conditional Imports
Use conditional imports to select the appropriate implementation:

```dart
import 'package:myapp/services/interfaces/map_service.dart';
import 'package:myapp/services/map_service.dart'
    if (dart.library.gms) 'package:myapp/services/gms/map_service.dart'
    if (dart.library.hms) 'package:myapp/services/hms/map_service.dart';
```

### Service Registration
Register services based on flavor:

```dart
void registerServices() {
  if (Platform.isAndroid) {
    if (isGMS) {
      sl.registerLazySingleton<MapService>(() => GMSMapService());
    } else {
      sl.registerLazySingleton<MapService>(() => HMSMapService());
    }
  }
}
```

## Building

### Debug Builds
```bash
# GMS Version
flutter run --flavor gms -t lib/main_gms.dart

# HMS Version
flutter run --flavor hms -t lib/main_hms.dart
```

### Release Builds
```bash
# GMS Version
flutter build apk --flavor gms -t lib/main_gms.dart

# HMS Version
flutter build apk --flavor hms -t lib/main_hms.dart
```

## Testing

### Unit Tests
```dart
void main() {
  group('Map Service Tests', () {
    test('GMS Map Service', () {
      // Test GMS implementation
    });

    test('HMS Map Service', () {
      // Test HMS implementation
    });
  });
}
```

### Integration Tests
```dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Map Integration Test', (tester) async {
    // Test with both implementations
  });
}
```

### Running Tests
```bash
# Run tests for GMS
flutter test --flavor gms

# Run tests for HMS
flutter test --flavor hms
