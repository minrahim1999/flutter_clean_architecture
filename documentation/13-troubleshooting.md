# Troubleshooting Guide

This guide helps you diagnose and fix common issues in the Flutter application.

## Table of Contents
1. [Common Issues](#common-issues)
2. [Build Problems](#build-problems)
3. [Runtime Errors](#runtime-errors)
4. [Performance Issues](#performance-issues)
5. [Network Problems](#network-problems)
6. [Platform-Specific Issues](#platform-specific-issues)

## Common Issues

### 1. App Crashes on Launch

**Symptoms:**
- App closes immediately after launch
- Black screen on startup
- Splash screen freezes

**Solutions:**

1. **Clear Build Files**
```bash
# Clean the project
flutter clean
flutter pub get
flutter run
```

2. **Check Dependencies**
```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  # Ensure versions are compatible
  flutter_bloc: ^8.1.6
  dio: ^5.4.0
```

3. **Check Error Logs**
```dart
// Add error logging
void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await initializeDependencies();
    runApp(const MyApp());
  }, (error, stack) {
    debugPrint('Error: $error\nStack: $stack');
  });
}
```

### 2. State Management Issues

**Symptoms:**
- UI not updating
- Inconsistent state
- BLoC events not working

**Solutions:**

1. **Check BLoC Implementation**
```dart
class FeatureBloc extends Bloc<FeatureEvent, FeatureState> {
  // Add debug prints
  @override
  void onTransition(Transition<FeatureEvent, FeatureState> transition) {
    super.onTransition(transition);
    debugPrint('Event: ${transition.event}');
    debugPrint('Current State: ${transition.currentState}');
    debugPrint('Next State: ${transition.nextState}');
  }
}
```

2. **Verify BlocProvider**
```dart
// Ensure proper BlocProvider setup
return MultiBlocProvider(
  providers: [
    BlocProvider<FeatureBloc>(
      create: (context) => sl<FeatureBloc>(),
    ),
  ],
  child: const App(),
);
```

3. **Debug State Changes**
```dart
// Add BlocObserver
class MyBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    debugPrint('Bloc: ${bloc.runtimeType}, Event: $event');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    debugPrint('Error in ${bloc.runtimeType}: $error');
    super.onError(bloc, error, stackTrace);
  }
}
```

## Build Problems

### 1. Android Build Issues

**Symptoms:**
- Gradle sync fails
- Build errors
- Version conflicts

**Solutions:**

1. **Update Gradle Configuration**
```groovy
// android/app/build.gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
        multiDexEnabled true
    }
}
```

2. **Fix Multidex Issues**
```groovy
dependencies {
    implementation 'androidx.multidex:multidex:2.0.1'
}
```

3. **Clear Gradle Cache**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

### 2. iOS Build Issues

**Symptoms:**
- Pod installation fails
- Xcode build errors
- Signing issues

**Solutions:**

1. **Update Pods**
```bash
cd ios
pod deintegrate
pod cache clean --all
pod install
cd ..
```

2. **Fix Signing**
```bash
# Open Xcode and update signing
open ios/Runner.xcworkspace
```

3. **Update Podfile**
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

## Runtime Errors

### 1. Memory Issues

**Symptoms:**
- App becomes slow
- High memory usage
- Random crashes

**Solutions:**

1. **Memory Leak Detection**
```dart
class MemoryMonitor {
  static void startMonitoring() {
    Timer.periodic(const Duration(seconds: 5), (timer) {
      debugPrint('Memory usage: ${ProcessInfo.currentRss}');
    });
  }
}
```

2. **Image Optimization**
```dart
class ImageOptimizer {
  static Future<File> optimizeImage(File file) async {
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes);
    if (image == null) return file;

    final optimized = img.copyResize(
      image,
      width: 1024,
      height: (1024 * image.height / image.width).round(),
    );
    
    return File(file.path)
      ..writeAsBytesSync(img.encodeJpg(optimized, quality: 85));
  }
}
```

3. **Widget Disposal**
```dart
class DisposableWidget extends StatefulWidget {
  @override
  void dispose() {
    // Clean up resources
    _subscription?.cancel();
    _controller?.dispose();
    super.dispose();
  }
}
```

### 2. Navigation Issues

**Symptoms:**
- Back button not working
- Wrong screen transitions
- Navigation stack problems

**Solutions:**

1. **Route Management**
```dart
class RouteManager {
  static final navigatorKey = GlobalKey<NavigatorState>();

  static Future<T?> navigateTo<T>(String route, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamed<T>(
      route,
      arguments: arguments,
    );
  }

  static void pop<T>([T? result]) {
    navigatorKey.currentState!.pop(result);
  }
}
```

2. **Navigation Logging**
```dart
class NavigationObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    debugPrint('Pushed route: ${route.settings.name}');
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    debugPrint('Popped route: ${route.settings.name}');
  }
}
```

## Performance Issues

### 1. UI Performance

**Symptoms:**
- Laggy scrolling
- Slow animations
- UI freezes

**Solutions:**

1. **Widget Optimization**
```dart
class OptimizedList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      // Use const where possible
      itemBuilder: (context, index) => const ListItem(),
      // Implement caching
      cacheExtent: 100,
    );
  }
}
```

2. **Build Optimization**
```dart
// Use const constructors
const MyWidget({Key? key}) : super(key: key);

// Implement shouldRebuild
@override
bool shouldRebuild(covariant SliverChildBuilderDelegate oldDelegate) {
  return data != oldDelegate.data;
}
```

3. **Performance Monitoring**
```dart
class PerformanceMonitor {
  static void trackBuildTime(String widgetName, VoidCallback build) {
    final stopwatch = Stopwatch()..start();
    build();
    debugPrint('$widgetName built in ${stopwatch.elapsedMilliseconds}ms');
  }
}
```

### 2. Network Performance

**Symptoms:**
- Slow API responses
- Timeout errors
- High data usage

**Solutions:**

1. **API Optimization**
```dart
class ApiClient {
  static final _cache = <String, dynamic>{};

  static Future<T> getCached<T>(
    String url,
    Future<T> Function() apiCall,
  ) async {
    if (_cache.containsKey(url)) {
      return _cache[url] as T;
    }
    final result = await apiCall();
    _cache[url] = result;
    return result;
  }
}
```

2. **Connection Management**
```dart
class ConnectionManager {
  static Future<bool> checkConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }
}
```

## Network Problems

### 1. API Connection Issues

**Symptoms:**
- API calls failing
- Timeout errors
- Network errors

**Solutions:**

1. **Network Error Handling**
```dart
class NetworkErrorHandler {
  static Future<T> handleApiCall<T>(
    Future<T> Function() apiCall,
  ) async {
    try {
      return await apiCall();
    } on DioException catch (e) {
      throw ApiException(
        message: _getErrorMessage(e),
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  static String _getErrorMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout';
      case DioExceptionType.receiveTimeout:
        return 'Receive timeout';
      case DioExceptionType.sendTimeout:
        return 'Send timeout';
      case DioExceptionType.badResponse:
        return 'Bad response: ${e.response?.statusCode}';
      default:
        return 'Network error occurred';
    }
  }
}
```

2. **Retry Mechanism**
```dart
class RetryManager {
  static Future<T> retryRequest<T>(
    Future<T> Function() request, {
    int maxAttempts = 3,
    Duration delay = const Duration(seconds: 1),
  }) async {
    int attempts = 0;
    while (attempts < maxAttempts) {
      try {
        return await request();
      } catch (e) {
        attempts++;
        if (attempts == maxAttempts) rethrow;
        await Future.delayed(delay * attempts);
      }
    }
    throw Exception('Max retry attempts reached');
  }
}
```

## Platform-Specific Issues

### 1. Android Issues

**Symptoms:**
- Permissions not working
- Notification issues
- Background tasks failing

**Solutions:**

1. **Permission Handling**
```dart
class AndroidPermissions {
  static Future<bool> requestPermission(Permission permission) async {
    if (await permission.isGranted) return true;
    
    final status = await permission.request();
    return status.isGranted;
  }

  static Future<void> openSettings() async {
    await openAppSettings();
  }
}
```

2. **Notification Setup**
```dart
class AndroidNotifications {
  static Future<void> createNotificationChannel() async {
    final flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
        
    const channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.high,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }
}
```

### 2. iOS Issues

**Symptoms:**
- Push notifications not working
- Background refresh issues
- Keychain access problems

**Solutions:**

1. **Push Notification Setup**
```dart
class IOSNotifications {
  static Future<void> requestPermissions() async {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('User granted permission: ${settings.authorizationStatus}');
  }
}
```

2. **Keychain Access**
```dart
class IOSKeychain {
  static Future<void> saveSecureData(String key, String value) async {
    await const FlutterSecureStorage().write(
      key: key,
      value: value,
      iOptions: const IOSOptions(
        accessibility: KeychainAccessibility.first_unlock,
      ),
    );
  }
}
```

## Best Practices

1. **Error Handling**
   - Implement global error handling
   - Log errors properly
   - Show user-friendly messages
   - Handle edge cases

2. **Performance**
   - Monitor app performance
   - Optimize resource usage
   - Cache when appropriate
   - Use lazy loading

3. **Testing**
   - Write comprehensive tests
   - Test error scenarios
   - Verify platform-specific code
   - Monitor crash reports

## Support Channels

1. **GitHub Issues**
   - Report bugs
   - Request features
   - Share solutions

2. **Discord Community**
   - Get real-time help
   - Share experiences
   - Discuss solutions

3. **Documentation**
   - Check guides
   - Read API docs
   - Follow tutorials

## Next Steps

1. Read the [Performance Guide](14-performance-guide.md)
2. Check the [Documentation Index](00-documentation-index.md)
3. Review the [Contributing Guide](11-contributing.md)

---

Next: [Performance Guide](14-performance-guide.md)
