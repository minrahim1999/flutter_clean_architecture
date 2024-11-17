# Getting Started Guide

This guide will help you set up and run the Flutter application on your local machine.

## Prerequisites

Before you begin, ensure you have the following installed:

1. **Flutter SDK**
   - Install [Flutter](https://flutter.dev/docs/get-started/install)
   - Run `flutter doctor` to verify installation
   - Required version: Latest stable (3.16.0 or higher)

2. **Dart SDK**
   - Included with Flutter SDK
   - Required version: 3.2.0 or higher

3. **IDE Setup**
   - [Android Studio](https://developer.android.com/studio) (recommended)
   - [VS Code](https://code.visualstudio.com/) with Flutter extension
   - Required plugins:
     - Flutter
     - Dart
     - Flutter Intl (for internationalization)

4. **Version Control**
   - [Git](https://git-scm.com/)

5. **Platform-specific Setup**

   **For Android:**
   - Android Studio
   - Android SDK (minimum API 21)
   - Android device or emulator

   **For iOS:**
   - Xcode (latest version)
   - CocoaPods
   - iOS device or simulator
   - macOS machine

## Installation Steps

1. **Clone the Repository**
   ```bash
   git clone https://github.com/yourusername/flutter-example.git
   cd flutter-example
   ```

2. **Install FVM (Flutter Version Management) - Optional but Recommended**
   ```bash
   dart pub global activate fvm
   fvm install
   ```

3. **Install Dependencies**
   ```bash
   flutter pub get
   ```

4. **Setup Environment Variables**
   ```bash
   cp .env.example .env
   ```
   Edit `.env` file with your configuration:
   ```env
   API_BASE_URL=your_api_url
   API_KEY=your_api_key
   ```

5. **Run Code Generation**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

## Running the Application

1. **Start a Device/Emulator**
   - Open Android Emulator
   - Or connect physical device
   - For iOS, open simulator or connect device

2. **Run the App**
   ```bash
   # Development
   flutter run

   # Production
   flutter run --release
   ```

3. **Run Tests**
   ```bash
   # Unit and Widget Tests
   flutter test

   # Integration Tests
   flutter test integration_test
   ```

## Project Configuration

### Android Setup

1. **Update Package Name**
   ```bash
   dart tools/scripts/update_app_name.dart "Your App Name"
   ```

2. **Firebase Setup (if needed)**
   - Add `google-services.json` to `android/app/`
   - Configure Firebase in `android/build.gradle`

### iOS Setup

1. **Update Bundle Identifier**
   - Open `ios/Runner.xcworkspace`
   - Update bundle identifier in Xcode
   - Or use the app name script above

2. **Pod Installation**
   ```bash
   cd ios
   pod install
   cd ..
   ```

## Common Issues and Solutions

1. **Build Errors**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

2. **Pod Issues (iOS)**
   ```bash
   cd ios
   pod deintegrate
   pod install
   cd ..
   ```

3. **Android Studio Issues**
   - File > Invalidate Caches / Restart

## Development Tools

1. **Feature Generation**
   ```bash
   dart tools/scripts/create_feature.dart feature_name
   ```

2. **Localization**
   ```bash
   flutter pub run intl_utils:generate
   ```

## Next Steps

1. Read the [Architecture Overview](02-architecture.md)
2. Learn about [Feature Development](03-feature-development.md)
3. Understand [State Management](04-state-management.md)

## Support

If you encounter any issues:
1. Check the [Troubleshooting Guide](08-troubleshooting.md)
2. Open an issue on GitHub
3. Contact the development team

---

Next: [Architecture Overview](02-architecture.md)
