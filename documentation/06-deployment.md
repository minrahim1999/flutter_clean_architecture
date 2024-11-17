# Deployment Guide

This guide outlines the deployment process for our Flutter application across different platforms.

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Android Deployment](#android-deployment)
3. [iOS Deployment](#ios-deployment)
4. [Web Deployment](#web-deployment)
5. [Desktop Deployment](#desktop-deployment)

## Prerequisites

### 1. Environment Setup

```bash
# Check Flutter installation
flutter doctor -v

# Update Flutter
flutter upgrade

# Clean project
flutter clean
flutter pub get
```

### 2. Version Management

```yaml
# pubspec.yaml
version: 1.0.0+1  # Format: version_name+version_code
```

### 3. Environment Variables

```dart
// lib/core/config/env.dart
class Environment {
  static const apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://api.staging.com',
  );

  static const apiKey = String.fromEnvironment(
    'API_KEY',
    defaultValue: '',
  );
}
```

## Android Deployment

### 1. Keystore Setup

```bash
# Generate keystore
keytool -genkey -v -keystore upload-keystore.jks \
  -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```

### 2. Gradle Configuration

```groovy
// android/app/build.gradle
android {
    signingConfigs {
        release {
            storeFile file("upload-keystore.jks")
            storePassword System.getenv("STORE_PASSWORD")
            keyAlias System.getenv("KEY_ALIAS")
            keyPassword System.getenv("KEY_PASSWORD")
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
}
```

### 3. Build APK/Bundle

```bash
# Build APK
flutter build apk --release

# Build App Bundle
flutter build appbundle --release
```

### 4. Play Store Deployment

1. **Prepare Store Listing**
   - App description
   - Screenshots
   - Feature graphic
   - Privacy policy

2. **Upload Bundle**
   ```bash
   # Upload to Play Store
   bundletool build-apks --bundle=app-release.aab \
     --output=app-release.apks \
     --ks=upload-keystore.jks \
     --ks-pass=pass:$KEY_PASSWORD \
     --ks-key-alias=upload
   ```

## iOS Deployment

### 1. Xcode Setup

```bash
# Open Xcode workspace
open ios/Runner.xcworkspace
```

### 2. Signing Configuration

```ruby
# ios/Podfile
platform :ios, '12.0'

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
    end
  end
end
```

### 3. Build IPA

```bash
# Build iOS release
flutter build ios --release

# Archive app in Xcode
xcodebuild -workspace ios/Runner.xcworkspace \
  -scheme Runner \
  -configuration Release \
  -archivePath build/Runner.xcarchive \
  archive

# Export IPA
xcodebuild -exportArchive \
  -archivePath build/Runner.xcarchive \
  -exportOptionsPlist exportOptions.plist \
  -exportPath build/ios
```

### 4. App Store Deployment

1. **App Store Connect Setup**
   - Create app
   - Configure metadata
   - Set up TestFlight

2. **Upload Build**
   ```bash
   # Upload to App Store
   xcrun altool --upload-app \
     -f build/ios/Runner.ipa \
     -u "apple@id.com" \
     -p "@keychain:AC_PASSWORD"
   ```

## Web Deployment

### 1. Web Configuration

```dart
// web/index.html
<!DOCTYPE html>
<html>
<head>
  <base href="$FLUTTER_BASE_HREF">
  <meta charset="UTF-8">
  <title>App Name</title>
  <script>
    // Firebase configuration
    const firebaseConfig = {
      apiKey: "your-api-key",
      authDomain: "your-auth-domain",
      projectId: "your-project-id",
    };
    firebase.initializeApp(firebaseConfig);
  </script>
</head>
<body>
  <script src="main.dart.js" type="application/javascript"></script>
</body>
</html>
```

### 2. Build Web

```bash
# Build web release
flutter build web --release

# Enable SKIA renderer
flutter build web --release --web-renderer canvaskit
```

### 3. Firebase Hosting

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize project
firebase init hosting

# Deploy to Firebase
firebase deploy --only hosting
```

### 4. Custom Domain Setup

```bash
# firebase.json
{
  "hosting": {
    "site": "your-app",
    "public": "build/web",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ]
  }
}
```

## Desktop Deployment

### 1. Windows Setup

```powershell
# Build Windows app
flutter build windows --release

# Create installer
iscc "installer.iss"
```

### 2. macOS Setup

```bash
# Build macOS app
flutter build macos --release

# Create DMG
create-dmg \
  --volname "App Name" \
  --window-pos 200 120 \
  --window-size 800 400 \
  --icon-size 100 \
  --icon "App.app" 200 190 \
  --hide-extension "App.app" \
  --app-drop-link 600 185 \
  "App.dmg" \
  "build/macos/Build/Products/Release/App.app"
```

### 3. Linux Setup

```bash
# Build Linux app
flutter build linux --release

# Create Debian package
dpkg-deb --build build/linux/x64/release/bundle
```

## CI/CD Setup

### 1. GitHub Actions

```yaml
# .github/workflows/ci.yml
name: CI/CD

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
      
      - name: Install dependencies
        run: flutter pub get
        
      - name: Run tests
        run: flutter test
        
      - name: Build APK
        run: flutter build apk --release
        
      - name: Upload APK
        uses: actions/upload-artifact@v2
        with:
          name: release-apk
          path: build/app/outputs/flutter-apk/app-release.apk
```

### 2. Fastlane Setup

```ruby
# fastlane/Fastfile
default_platform(:android)

platform :android do
  desc "Deploy to Play Store"
  lane :deploy do
    gradle(
      task: 'bundle',
      build_type: 'Release'
    )
    upload_to_play_store(
      track: 'internal',
      aab: '../build/app/outputs/bundle/release/app-release.aab'
    )
  end
end

platform :ios do
  desc "Deploy to App Store"
  lane :deploy do
    build_ios_app(
      workspace: "Runner.xcworkspace",
      scheme: "Runner",
      export_method: "app-store"
    )
    upload_to_app_store(
      skip_screenshots: true,
      skip_metadata: true
    )
  end
end
```

## Best Practices

1. **Version Control**
   - Use semantic versioning
   - Tag releases
   - Maintain changelog
   - Branch management

2. **Security**
   - Secure API keys
   - Enable ProGuard
   - Certificate pinning
   - App signing

3. **Performance**
   - Optimize assets
   - Enable R8
   - Minimize app size
   - Profile release builds

## Next Steps

1. Review the [Flavor Configuration](07-flavor-configuration.md)
2. Check the [Plugin Development](08-plugin-development.md)
3. Read the [Platform Integration](09-platform-integration.md)

---

Next: [Flavor Configuration](07-flavor-configuration.md)
