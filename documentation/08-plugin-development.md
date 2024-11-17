# Plugin Development Guide

This guide explains how to create, test, and publish Flutter plugins for our application.

## Table of Contents
1. [Plugin Basics](#plugin-basics)
2. [Creating a Plugin](#creating-a-plugin)
3. [Platform Integration](#platform-integration)
4. [Testing Plugins](#testing-plugins)
5. [Publishing Plugins](#publishing-plugins)

## Plugin Basics

Flutter plugins allow you to:
- Access platform-specific APIs
- Integrate native functionality
- Share code between applications
- Create reusable components

### Types of Plugins

1. **Platform Plugins**
   - Access native APIs
   - Platform-specific functionality
   - Hardware access

2. **Dart-only Plugins**
   - Pure Dart implementation
   - Cross-platform functionality
   - Utility libraries

3. **Federated Plugins**
   - Split into multiple packages
   - Platform-specific implementations
   - Shared interfaces

## Creating a Plugin

### 1. Generate Plugin Template

```bash
# Create a new plugin
flutter create --org com.example --template=plugin example_plugin

# For a federated plugin
flutter create --org com.example --template=plugin --platforms=android,ios example_plugin
```

### 2. Plugin Structure

```
example_plugin/
├── android/                 # Android platform code
├── ios/                     # iOS platform code
├── lib/                     # Dart code
├── test/                    # Plugin tests
├── example/                 # Example app
├── pubspec.yaml            # Plugin metadata
└── README.md               # Documentation
```

### 3. Define Plugin Interface

```dart
// lib/example_plugin.dart

class ExamplePlugin {
  static const MethodChannel _channel = MethodChannel('example_plugin');

  static Future<String?> getPlatformVersion() async {
    final version = await _channel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  static Future<void> performNativeOperation({
    required String data,
    Map<String, dynamic>? options,
  }) async {
    await _channel.invokeMethod('performNativeOperation', {
      'data': data,
      'options': options,
    });
  }
}
```

## Platform Integration

### Android Implementation

1. **Setup Kotlin Code**
```kotlin
// android/src/main/kotlin/com/example/example_plugin/ExamplePlugin.kt

class ExamplePlugin: FlutterPlugin, MethodCallHandler {
  private lateinit var channel: MethodChannel

  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(binding.binaryMessenger, "example_plugin")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "getPlatformVersion" -> {
        result.success("Android ${android.os.Build.VERSION.RELEASE}")
      }
      "performNativeOperation" -> {
        val data = call.argument<String>("data")
        val options = call.argument<Map<String, Any>>("options")
        
        try {
          // Perform native operation
          result.success(null)
        } catch (e: Exception) {
          result.error("ERROR", e.message, null)
        }
      }
      else -> {
        result.notImplemented()
      }
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
```

2. **Add Android Permissions**
```xml
<!-- android/src/main/AndroidManifest.xml -->
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
  package="com.example.example_plugin">
  <!-- Add required permissions -->
  <uses-permission android:name="android.permission.INTERNET"/>
</manifest>
```

### iOS Implementation

1. **Setup Swift Code**
```swift
// ios/Classes/SwiftExamplePlugin.swift

public class SwiftExamplePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "example_plugin",
      binaryMessenger: registrar.messenger()
    )
    let instance = SwiftExamplePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    case "performNativeOperation":
      guard let args = call.arguments as? [String: Any],
            let data = args["data"] as? String,
            let options = args["options"] as? [String: Any] else {
        result(FlutterError(
          code: "INVALID_ARGUMENTS",
          message: "Invalid arguments",
          details: nil
        ))
        return
      }
      
      // Perform native operation
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
```

2. **Update Pod Spec**
```ruby
# ios/example_plugin.podspec

Pod::Spec.new do |s|
  s.name             = 'example_plugin'
  s.version          = '0.0.1'
  s.summary          = 'Example plugin description'
  s.description      = <<-DESC
A new Flutter plugin for example functionality.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform         = :ios, '11.0'
  
  # Add any iOS-specific dependencies
  # s.dependency 'SomeIOSLibrary'
end
```

## Testing Plugins

### 1. Unit Tests

```dart
// test/example_plugin_test.dart

void main() {
  const MethodChannel channel = MethodChannel('example_plugin');
  final List<MethodCall> log = <MethodCall>[];

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      log.add(methodCall);
      switch (methodCall.method) {
        case 'getPlatformVersion':
          return '42';
        default:
          return null;
      }
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
    log.clear();
  });

  test('getPlatformVersion', () async {
    expect(await ExamplePlugin.getPlatformVersion(), '42');
    expect(
      log,
      <Matcher>[isMethodCall('getPlatformVersion', arguments: null)],
    );
  });
}
```

### 2. Integration Tests

```dart
// example/integration_test/plugin_integration_test.dart

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('getPlatformVersion test', (WidgetTester tester) async {
    final String? version = await ExamplePlugin.getPlatformVersion();
    expect(version?.isNotEmpty, true);
  });
}
```

### 3. Platform Tests

For Android:
```kotlin
// android/src/test/kotlin/com/example/example_plugin/ExamplePluginTest.kt

@RunWith(RobolectricTestRunner::class)
class ExamplePluginTest {
  @Test
  fun onMethodCall_getPlatformVersion_returnsExpectedValue() {
    val plugin = ExamplePlugin()
    val call = MethodCall("getPlatformVersion", null)
    val mockResult = mock<Result>()

    plugin.onMethodCall(call, mockResult)

    verify(mockResult).success(matches("Android .*"))
  }
}
```

For iOS:
```swift
// ios/Tests/ExamplePluginTests.swift

class ExamplePluginTests: XCTestCase {
  func testGetPlatformVersion() {
    let plugin = SwiftExamplePlugin()
    let call = FlutterMethodCall(
      methodName: "getPlatformVersion",
      arguments: nil
    )
    
    var result: String?
    plugin.handle(call) { response in
      result = response as? String
    }
    
    XCTAssertTrue(result?.starts(with: "iOS") ?? false)
  }
}
```

## Publishing Plugins

### 1. Prepare for Publication

1. **Update pubspec.yaml**
```yaml
name: example_plugin
description: A detailed description of your plugin
version: 1.0.0
homepage: https://github.com/yourusername/example_plugin

environment:
  sdk: ">=3.0.0 <4.0.0"
  flutter: ">=3.0.0"

dependencies:
  flutter:
    sdk: flutter

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0

flutter:
  plugin:
    platforms:
      android:
        package: com.example.example_plugin
        pluginClass: ExamplePlugin
      ios:
        pluginClass: ExamplePlugin
```

2. **Update README.md**
```markdown
# Example Plugin

A detailed description of your plugin.

## Features

- Feature 1
- Feature 2

## Getting started

Install the plugin:

```yaml
dependencies:
  example_plugin: ^1.0.0
```

## Usage

```dart
import 'package:example_plugin/example_plugin.dart';

// Get platform version
final version = await ExamplePlugin.getPlatformVersion();

// Perform native operation
await ExamplePlugin.performNativeOperation(
  data: 'example',
  options: {'key': 'value'},
);
```

### 2. Publish to pub.dev

1. **Verify Package**
```bash
flutter pub publish --dry-run
```

2. **Publish Package**
```bash
flutter pub publish
```

## Best Practices

1. **Code Organization**
   - Keep platform code separate
   - Use clear interfaces
   - Document public APIs

2. **Error Handling**
   - Handle all edge cases
   - Provide meaningful errors
   - Use typed exceptions

3. **Testing**
   - Write comprehensive tests
   - Test platform-specific code
   - Include integration tests

4. **Documentation**
   - Clear API documentation
   - Usage examples
   - Platform-specific notes

## Troubleshooting

### Common Issues

1. **Method Channel Issues**
   - Check channel names match
   - Verify argument types
   - Debug method calls

2. **Platform Integration**
   - Check platform setup
   - Verify permissions
   - Test on all platforms

3. **Publishing Issues**
   - Validate pubspec.yaml
   - Check dependencies
   - Verify licenses

## Next Steps

1. Check the [Platform Integration Guide](09-platform-integration.md)
2. Review the [Security Guide](10-security-guide.md)
3. Read the [Contributing Guide](11-contributing.md)

---

Next: [Platform Integration Guide](09-platform-integration.md)
