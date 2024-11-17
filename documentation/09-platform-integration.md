# Platform Integration Guide

This guide explains how to integrate platform-specific features and ensure your Flutter application works seamlessly across different platforms.

## Table of Contents
1. [Android Integration](#android-integration)
2. [iOS Integration](#ios-integration)
3. [Web Support](#web-support)
4. [Desktop Support](#desktop-support)
5. [Platform-Specific Code](#platform-specific-code)

## Android Integration

### 1. Android Project Setup

1. **Gradle Configuration**
```groovy
// android/app/build.gradle

android {
    compileSdkVersion 34
    
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
}
```

2. **Permissions Setup**
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Internet Permission -->
    <uses-permission android:name="android.permission.INTERNET"/>
    
    <!-- Camera Permission -->
    <uses-permission android:name="android.permission.CAMERA"/>
    
    <!-- Location Permissions -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
</manifest>
```

3. **Native Activity Configuration**
```kotlin
// android/app/src/main/kotlin/com/example/app/MainActivity.kt

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Register platform channels
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "platform_channel")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getPlatformVersion" -> result.success(android.os.Build.VERSION.RELEASE)
                    else -> result.notImplemented()
                }
            }
    }
}
```

### 2. Firebase Integration

1. **Setup Firebase**
```groovy
// android/build.gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
    }
}

// android/app/build.gradle
apply plugin: 'com.google.gms.google-services'

dependencies {
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    implementation 'com.google.firebase:firebase-analytics'
}
```

2. **Configure Firebase**
- Add `google-services.json` to `android/app/`
- Initialize Firebase in MainActivity

### 3. Push Notifications

1. **FCM Setup**
```kotlin
class FirebaseMessagingService : FirebaseMessagingService() {
    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        // Handle FCM messages
    }

    override fun onNewToken(token: String) {
        // Handle new FCM tokens
    }
}
```

## iOS Integration

### 1. iOS Project Setup

1. **Podfile Configuration**
```ruby
# ios/Podfile
platform :ios, '12.0'

target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
  
  # Add specific pods
  pod 'Firebase/Analytics'
  pod 'Firebase/Messaging'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
    end
  end
end
```

2. **Info.plist Configuration**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Camera Permission -->
    <key>NSCameraUsageDescription</key>
    <string>This app needs camera access to scan QR codes</string>
    
    <!-- Location Permission -->
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>This app needs location access to provide location-based services</string>
    
    <!-- Push Notifications -->
    <key>UIBackgroundModes</key>
    <array>
        <string>remote-notification</string>
    </array>
</dict>
</plist>
```

3. **Swift Integration**
```swift
// ios/Runner/AppDelegate.swift

import UIKit
import Flutter
import Firebase

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        FirebaseApp.configure()
        
        let controller = window?.rootViewController as! FlutterViewController
        let channel = FlutterMethodChannel(
            name: "platform_channel",
            binaryMessenger: controller.binaryMessenger
        )
        
        channel.setMethodCallHandler { call, result in
            switch call.method {
            case "getPlatformVersion":
                result(UIDevice.current.systemVersion)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
```

### 2. Push Notifications

1. **Setup Push Notifications**
```swift
extension AppDelegate {
    override func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    override func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable : Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        // Handle push notification
        completionHandler(.newData)
    }
}
```

## Web Support

### 1. Web Configuration

1. **Enable Web Support**
```bash
flutter config --enable-web
```

2. **Web-specific Code**
```dart
// lib/core/platform/web_platform.dart
import 'dart:html' as html;

class WebPlatform {
  static void initializeWeb() {
    // Web-specific initialization
  }
  
  static void registerServiceWorker() {
    if (html.window.navigator.serviceWorker != null) {
      html.window.navigator.serviceWorker
          .register('flutter_service_worker.js');
    }
  }
}
```

3. **Index.html Configuration**
```html
<!-- web/index.html -->
<!DOCTYPE html>
<html>
<head>
  <base href="$FLUTTER_BASE_HREF">
  <meta charset="UTF-8">
  <title>App Name</title>
  <script src="https://www.gstatic.com/firebasejs/9.x.x/firebase-app.js"></script>
  <script src="https://www.gstatic.com/firebasejs/9.x.x/firebase-analytics.js"></script>
</head>
<body>
  <script>
    // Firebase configuration
    const firebaseConfig = {
      // Your web app's Firebase configuration
    };
    firebase.initializeApp(firebaseConfig);
  </script>
  <script src="main.dart.js" type="application/javascript"></script>
</body>
</html>
```

## Desktop Support

### 1. Windows Configuration

1. **Enable Windows Support**
```bash
flutter config --enable-windows-desktop
```

2. **Windows-specific Code**
```dart
// lib/core/platform/windows_platform.dart
import 'package:win32/win32.dart';

class WindowsPlatform {
  static void initializeWindows() {
    // Windows-specific initialization
  }
  
  static Future<void> setupWindowsNotifications() async {
    // Setup Windows notifications
  }
}
```

### 2. macOS Configuration

1. **Enable macOS Support**
```bash
flutter config --enable-macos-desktop
```

2. **Entitlements Setup**
```xml
<!-- macos/Runner/DebugProfile.entitlements -->
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.app-sandbox</key>
    <true/>
    <key>com.apple.security.network.client</key>
    <true/>
</dict>
</plist>
```

## Platform-Specific Code

### 1. Platform Channels

```dart
// lib/core/platform/platform_channel.dart
import 'package:flutter/services.dart';

class PlatformChannel {
  static const platform = MethodChannel('platform_channel');

  static Future<String> getPlatformVersion() async {
    try {
      final version = await platform.invokeMethod<String>('getPlatformVersion');
      return version ?? 'Unknown';
    } on PlatformException catch (e) {
      return 'Failed to get platform version: ${e.message}';
    }
  }
}
```

### 2. Conditional Platform Code

```dart
// lib/core/platform/platform_helper.dart
import 'dart:io';
import 'package:flutter/foundation.dart';

class PlatformHelper {
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;
  static bool get isIOS => !kIsWeb && Platform.isIOS;
  static bool get isWeb => kIsWeb;
  static bool get isWindows => !kIsWeb && Platform.isWindows;
  static bool get isMacOS => !kIsWeb && Platform.isMacOS;
  static bool get isLinux => !kIsWeb && Platform.isLinux;
  static bool get isMobile => isAndroid || isIOS;
  static bool get isDesktop => isWindows || isMacOS || isLinux;

  static T platformSelect<T>({
    required T android,
    required T ios,
    T? web,
    T? windows,
    T? macOS,
    T? linux,
    T? fallback,
  }) {
    if (isAndroid) return android;
    if (isIOS) return ios;
    if (isWeb) return web ?? fallback ?? android;
    if (isWindows) return windows ?? fallback ?? android;
    if (isMacOS) return macOS ?? fallback ?? ios;
    if (isLinux) return linux ?? fallback ?? android;
    return fallback ?? android;
  }
}
```

### 3. Platform-Specific Widgets

```dart
// lib/core/widgets/platform_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

abstract class PlatformWidget extends StatelessWidget {
  const PlatformWidget({Key? key}) : super(key: key);

  Widget buildCupertinoWidget(BuildContext context);
  Widget buildMaterialWidget(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return PlatformHelper.platformSelect(
      ios: buildCupertinoWidget(context),
      android: buildMaterialWidget(context),
      fallback: buildMaterialWidget(context),
    );
  }
}

// Example Usage
class PlatformButton extends PlatformWidget {
  final String text;
  final VoidCallback onPressed;

  const PlatformButton({
    required this.text,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget buildCupertinoWidget(BuildContext context) {
    return CupertinoButton(
      onPressed: onPressed,
      child: Text(text),
    );
  }

  @override
  Widget buildMaterialWidget(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(text),
    );
  }
}
```

## Best Practices

1. **Platform Detection**
   - Use platform-specific checks
   - Handle web platform separately
   - Provide fallbacks

2. **Code Organization**
   - Separate platform-specific code
   - Use abstract interfaces
   - Implement platform factories

3. **Resource Management**
   - Handle assets per platform
   - Manage platform dependencies
   - Consider platform limitations

4. **Testing**
   - Test on all target platforms
   - Use platform-specific mocks
   - Verify platform behavior

## Next Steps

1. Review the [Security Guide](10-security-guide.md)
2. Read the [Contributing Guide](11-contributing.md)
3. Check the [Future Features](12-future-features.md)

---

Next: [Security Guide](10-security-guide.md)
