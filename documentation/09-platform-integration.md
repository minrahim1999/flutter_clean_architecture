# Platform Integration Guide

This guide covers platform-specific integration for Android (GMS/HMS), iOS, and other supported platforms.

## Table of Contents
1. [Android Integration](#android-integration)
   - [GMS Setup](#gms-setup)
   - [HMS Setup](#hms-setup)
   - [Common Configuration](#android-common-configuration)
2. [iOS Integration](#ios-integration)
3. [Web Support](#web-support)
4. [Desktop Platforms](#desktop-platforms)

## Android Integration

### GMS Setup

1. **Google Services Configuration**
```groovy
// android/build.gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
    }
}

// android/app/build.gradle
apply plugin: 'com.google.gms.google-services'
```

2. **Dependencies**
```groovy
dependencies {
    gmsImplementation 'com.google.android.gms:play-services-base:18.2.0'
    gmsImplementation 'com.google.android.gms:play-services-maps:18.2.0'
    gmsImplementation 'com.google.firebase:firebase-analytics:21.5.0'
}
```

3. **Manifest Configuration**
```xml
<manifest>
    <application>
        <!-- Google Maps API Key -->
        <meta-data
            android:name="com.google.android.geo.API_KEY"
            android:value="your_google_maps_key"/>
    </application>
</manifest>
```

### HMS Setup

1. **Huawei Services Configuration**
```groovy
// android/build.gradle
buildscript {
    repositories {
        maven { url 'https://developer.huawei.com/repo/' }
    }
    dependencies {
        classpath 'com.huawei.agconnect:agcp:1.9.1.301'
    }
}

// android/app/build.gradle
apply plugin: 'com.huawei.agconnect'
```

2. **Dependencies**
```groovy
dependencies {
    hmsImplementation 'com.huawei.hms:base:6.11.0.300'
    hmsImplementation 'com.huawei.hms:maps:6.11.1.301'
    hmsImplementation 'com.huawei.agconnect:agconnect-core:1.9.1.301'
}
```

3. **Manifest Configuration**
```xml
<manifest>
    <application>
        <!-- Huawei Maps API Key -->
        <meta-data
            android:name="com.huawei.hms.client.api_key"
            android:value="your_huawei_maps_key"/>
    </application>
</manifest>
```

### Android Common Configuration

1. **Permissions**
```xml
<manifest>
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
</manifest>
```

2. **Proguard Rules**
```proguard
# Common rules
-keep class * implements com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# GMS specific rules
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# HMS specific rules
-keep class com.huawei.hms.** { *; }
-dontwarn com.huawei.hms.**
```

## iOS Integration

1. **Pod Configuration**
```ruby
# ios/Podfile
target 'Runner' do
  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
  
  # Google Maps
  pod 'GoogleMaps'
  pod 'Google-Maps-iOS-Utils'
end
```

2. **Info.plist Configuration**
```xml
<dict>
    <!-- Location permissions -->
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>This app needs access to location when open to show your position on the map.</string>
    
    <!-- Google Maps configuration -->
    <key>GMSApiKey</key>
    <string>your_google_maps_key</string>
</dict>
```

## Web Support

1. **Index.html Configuration**
```html
<!DOCTYPE html>
<html>
<head>
  <!-- Google Maps JavaScript API -->
  <script src="https://maps.googleapis.com/maps/api/js?key=your_api_key"></script>
  
  <!-- HMS WebView component (for HMS web support) -->
  <script src="https://mapkit.map.hms.huawei.com/map/mapkit.js"></script>
</head>
<body>
  <script>
    // Initialize platform-specific services
    if (typeof google !== 'undefined') {
      window.initializeGoogleMaps = function() {
        // Initialize Google Maps
      };
    } else if (typeof HWMapJsSDK !== 'undefined') {
      window.initializeHuaweiMaps = function() {
        // Initialize Huawei Maps
      };
    }
  </script>
</body>
</html>
```

## Desktop Platforms

1. **Windows Configuration**
```yaml
# windows/runner/Runner.rc
IDI_APP_ICON            ICON                    "resources\\app_icon.ico"
```

2. **macOS Configuration**
```xml
<!-- macos/Runner/Info.plist -->
<dict>
    <key>LSApplicationCategoryType</key>
    <string>public.app-category.utilities</string>
</dict>
```

3. **Linux Configuration**
```desktop
# linux/my_application.desktop
[Desktop Entry]
Name=My App
Comment=My Flutter Application
Exec=my_app
Icon=my_app
Terminal=false
Type=Application
Categories=Utility;
```

## Common Integration Points

1. **Platform Channels**
```dart
const platform = MethodChannel('com.myapp/platform_services');

Future<void> invokeNativeMethod() async {
  try {
    final result = await platform.invokeMethod('nativeMethod');
    print(result);
  } on PlatformException catch (e) {
    print('Error: ${e.message}');
  }
}
```

2. **Platform-Specific Code**
```dart
import 'package:flutter/foundation.dart';

class PlatformService {
  void initialize() {
    if (Platform.isAndroid) {
      if (isGMS) {
        // Initialize GMS
      } else {
        // Initialize HMS
      }
    } else if (Platform.isIOS) {
      // Initialize iOS services
    } else if (kIsWeb) {
      // Initialize web services
    }
  }
}
```

3. **Error Handling**
```dart
try {
  await platformService.initialize();
} on PlatformException catch (e) {
  print('Platform error: ${e.message}');
} on MissingPluginException catch (e) {
  print('Plugin not available: ${e.message}');
} catch (e) {
  print('General error: $e');
}
```
