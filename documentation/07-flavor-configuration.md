# Flavor Configuration Guide

This guide explains how to set up and use different build flavors in the Flutter application.

## Table of Contents
1. [Understanding Flavors](#understanding-flavors)
2. [Flavor Types](#flavor-types)
3. [Configuration Steps](#configuration-steps)
4. [Usage Guide](#usage-guide)
5. [CI/CD Integration](#cicd-integration)

## Understanding Flavors

Flavors (also known as build variants in Android or schemes in iOS) allow you to create different versions of your app with different configurations.

Common use cases:
- Different environments (dev, staging, prod)
- White-label applications
- Free vs. paid versions
- Different API endpoints

## Flavor Types

Our project supports these flavors:

1. **Development**
   - Development API endpoints
   - Debug features enabled
   - Test accounts
   - Analytics disabled

2. **Staging**
   - Staging API endpoints
   - Limited debug features
   - Test data
   - Analytics enabled

3. **Production**
   - Production API endpoints
   - No debug features
   - Real data
   - Analytics enabled

## Configuration Steps

### 1. Android Configuration

1. **Edit build.gradle**
```groovy
// android/app/build.gradle

android {
    flavorDimensions "environment"
    productFlavors {
        development {
            dimension "environment"
            applicationIdSuffix ".dev"
            resValue "string", "app_name", "MyApp Dev"
        }
        staging {
            dimension "environment"
            applicationIdSuffix ".staging"
            resValue "string", "app_name", "MyApp Staging"
        }
        production {
            dimension "environment"
            resValue "string", "app_name", "MyApp"
        }
    }
}
```

2. **Create flavor-specific folders**
```bash
android/app/src/development/
android/app/src/staging/
android/app/src/production/
```

3. **Add flavor-specific files**
```bash
# Example: google-services.json
android/app/src/development/google-services.json
android/app/src/staging/google-services.json
android/app/src/production/google-services.json
```

### 2. iOS Configuration

1. **Create Configurations**
   - Open Xcode
   - Project > Info > Configurations
   - Add Development and Staging configurations

2. **Edit xcconfig files**
```xcconfig
// ios/Flutter/Development.xcconfig
#include "Generated.xcconfig"
FLUTTER_TARGET=lib/main_development.dart
FLUTTER_FLAVOR=development
PRODUCT_BUNDLE_IDENTIFIER=com.example.app.dev
DISPLAY_NAME=MyApp Dev

// ios/Flutter/Staging.xcconfig
#include "Generated.xcconfig"
FLUTTER_TARGET=lib/main_staging.dart
FLUTTER_FLAVOR=staging
PRODUCT_BUNDLE_IDENTIFIER=com.example.app.staging
DISPLAY_NAME=MyApp Staging

// ios/Flutter/Production.xcconfig
#include "Generated.xcconfig"
FLUTTER_TARGET=lib/main_production.dart
FLUTTER_FLAVOR=production
PRODUCT_BUNDLE_IDENTIFIER=com.example.app
DISPLAY_NAME=MyApp
```

### 3. Flutter Configuration

1. **Create flavor-specific entry points**
```dart
// lib/main_development.dart
void main() {
  bootstrap(() => const App(), Environment.development);
}

// lib/main_staging.dart
void main() {
  bootstrap(() => const App(), Environment.staging);
}

// lib/main_production.dart
void main() {
  bootstrap(() => const App(), Environment.production);
}
```

2. **Create environment configuration**
```dart
// lib/core/config/env.dart
enum Environment {
  development,
  staging,
  production
}

class EnvironmentConfig {
  static const environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );

  static Environment get currentEnvironment {
    switch (environment) {
      case 'development':
        return Environment.development;
      case 'staging':
        return Environment.staging;
      case 'production':
        return Environment.production;
      default:
        return Environment.development;
    }
  }

  static String get apiBaseUrl {
    switch (currentEnvironment) {
      case Environment.development:
        return 'https://dev-api.example.com';
      case Environment.staging:
        return 'https://staging-api.example.com';
      case Environment.production:
        return 'https://api.example.com';
    }
  }

  static bool get shouldCollectCrashlytics {
    switch (currentEnvironment) {
      case Environment.development:
        return false;
      case Environment.staging:
      case Environment.production:
        return true;
    }
  }
}
```

## Usage Guide

### Running Different Flavors

1. **Command Line**
```bash
# Development
flutter run --flavor development -t lib/main_development.dart

# Staging
flutter run --flavor staging -t lib/main_staging.dart

# Production
flutter run --flavor production -t lib/main_production.dart
```

2. **VS Code**
Add to `.vscode/launch.json`:
```json
{
  "configurations": [
    {
      "name": "Development",
      "request": "launch",
      "type": "dart",
      "program": "lib/main_development.dart",
      "args": ["--flavor", "development"]
    },
    {
      "name": "Staging",
      "request": "launch",
      "type": "dart",
      "program": "lib/main_staging.dart",
      "args": ["--flavor", "staging"]
    },
    {
      "name": "Production",
      "request": "launch",
      "type": "dart",
      "program": "lib/main_production.dart",
      "args": ["--flavor", "production"]
    }
  ]
}
```

3. **Android Studio**
   - Edit Configurations
   - Add New Flutter Configuration
   - Set flavor and target file

### Building Release Versions

1. **Android**
```bash
# APK
flutter build apk --flavor production -t lib/main_production.dart

# App Bundle
flutter build appbundle --flavor production -t lib/main_production.dart
```

2. **iOS**
```bash
flutter build ios --flavor production -t lib/main_production.dart
```

## CI/CD Integration

### GitHub Actions Example
```yaml
name: Build and Deploy

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        flavor: [development, staging, production]
    
    steps:
      - uses: actions/checkout@v2
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
          
      - name: Build APK
        run: flutter build apk --flavor ${{ matrix.flavor }} -t lib/main_${{ matrix.flavor }}.dart
```

### Fastlane Integration
```ruby
# fastlane/Fastfile

lane :build_and_deploy do |options|
  flavor = options[:flavor]
  
  build_android_app(
    flavor: flavor,
    task: 'assemble',
    build_type: 'Release'
  )
  
  build_ios_app(
    scheme: flavor,
    configuration: 'Release'
  )
end
```

## Best Practices

1. **Environment Variables**
   - Keep sensitive data out of source control
   - Use different values per flavor
   - Use `.env` files

2. **Asset Management**
   - Organize assets by flavor
   - Use flavor-specific icons and splash screens
   - Maintain consistent naming

3. **Code Organization**
   - Keep flavor-specific code minimal
   - Use dependency injection for configuration
   - Abstract environment-specific logic

4. **Testing**
   - Test all flavors
   - Use mock environments
   - Automate flavor testing

## Troubleshooting

### Common Issues

1. **Build Errors**
```bash
flutter clean
flutter pub get
```

2. **iOS Signing Issues**
   - Update provisioning profiles
   - Check bundle identifiers
   - Verify certificates

3. **Android Package Name Conflicts**
   - Check applicationId in build.gradle
   - Verify manifest package names
   - Clear build cache

## Next Steps

1. Read the [Plugin Development Guide](08-plugin-development.md)
2. Check the [Platform Integration Guide](09-platform-integration.md)
3. Review the [Security Guide](10-security-guide.md)

---

Next: [Plugin Development Guide](08-plugin-development.md)
