# Security Guide

This guide outlines security best practices and implementations for our Flutter application.

## Table of Contents
1. [Authentication](#authentication)
2. [Data Encryption](#data-encryption)
3. [Secure Storage](#secure-storage)
4. [Network Security](#network-security)
5. [Code Security](#code-security)
6. [Platform Security](#platform-security)

## Authentication

### 1. JWT Authentication

```dart
// lib/core/auth/jwt_auth.dart
class JwtAuth {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'jwt_token';
  static const _refreshTokenKey = 'refresh_token';

  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  static Future<void> setToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<void> clearTokens() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  static bool isTokenExpired(String token) {
    try {
      final jwt = JWT.decode(token);
      final exp = jwt.payload['exp'] as int;
      return DateTime.fromMillisecondsSinceEpoch(exp * 1000)
          .isBefore(DateTime.now());
    } catch (e) {
      return true;
    }
  }
}
```

### 2. Biometric Authentication

```dart
// lib/core/auth/biometric_auth.dart
class BiometricAuth {
  static final _localAuth = LocalAuthentication();

  static Future<bool> isBiometricAvailable() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> authenticate() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Please authenticate to continue',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }
}
```

### 3. OAuth Implementation

```dart
// lib/core/auth/oauth_auth.dart
class OAuthAuth {
  static final _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  static Future<AuthCredential?> signInWithGoogle() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return null;

      final auth = await account.authentication;
      return GoogleAuthProvider.credential(
        accessToken: auth.accessToken,
        idToken: auth.idToken,
      );
    } catch (e) {
      return null;
    }
  }
}
```

## Data Encryption

### 1. Local Data Encryption

```dart
// lib/core/security/encryption.dart
class Encryption {
  static final _key = encrypt.Key.fromSecureRandom(32);
  static final _iv = encrypt.IV.fromSecureRandom(16);
  static final _encrypter = encrypt.Encrypter(encrypt.AES(_key));

  static String encrypt(String data) {
    return _encrypter.encrypt(data, iv: _iv).base64;
  }

  static String decrypt(String encrypted) {
    try {
      return _encrypter.decrypt64(encrypted, iv: _iv);
    } catch (e) {
      return '';
    }
  }

  static Future<void> encryptFile(String path) async {
    final file = File(path);
    final bytes = await file.readAsBytes();
    final encrypted = _encrypter.encryptBytes(bytes, iv: _iv);
    await file.writeAsBytes(encrypted.bytes);
  }
}
```

### 2. Secure Key Storage

```dart
// lib/core/security/key_storage.dart
class KeyStorage {
  static const _storage = FlutterSecureStorage();

  static Future<void> storeKey(String key, String value) async {
    await _storage.write(
      key: key,
      value: value,
      aOptions: const AndroidOptions(
        encryptedSharedPreferences: true,
      ),
      iOptions: const IOSOptions(
        accessibility: KeychainAccessibility.first_unlock,
      ),
    );
  }

  static Future<String?> getKey(String key) async {
    return await _storage.read(
      key: key,
      aOptions: const AndroidOptions(
        encryptedSharedPreferences: true,
      ),
      iOptions: const IOSOptions(
        accessibility: KeychainAccessibility.first_unlock,
      ),
    );
  }
}
```

## Secure Storage

### 1. Secure Preferences

```dart
// lib/core/storage/secure_preferences.dart
class SecurePreferences {
  static late SharedPreferences _prefs;
  static const _encryptionKey = 'encryption_key';

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> setSecureString(String key, String value) async {
    final encrypted = Encryption.encrypt(value);
    await _prefs.setString(key, encrypted);
  }

  static String? getSecureString(String key) {
    final encrypted = _prefs.getString(key);
    if (encrypted == null) return null;
    return Encryption.decrypt(encrypted);
  }

  static Future<void> clearSecureData() async {
    await _prefs.clear();
  }
}
```

### 2. Database Encryption

```dart
// lib/core/storage/encrypted_database.dart
class EncryptedDatabase {
  static Database? _database;
  static const _databaseName = 'app.db';
  static const _databaseVersion = 1;

  static Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final path = await getDatabasesPath();
    final dbPath = join(path, _databaseName);

    // Use SQLCipher for encryption
    return await openDatabase(
      dbPath,
      version: _databaseVersion,
      onCreate: _onCreate,
      password: await KeyStorage.getKey('db_key'),
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL
      )
    ''');
  }
}
```

## Network Security

### 1. Certificate Pinning

```dart
// lib/core/network/certificate_pinning.dart
class CertificatePinning {
  static Dio createPinnedClient() {
    final dio = Dio();
    
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.badCertificateCallback = (cert, host, port) {
          return _validateCertificate(cert.pem);
        };
        return client;
      },
    );

    return dio;
  }

  static bool _validateCertificate(String certificate) {
    const validCertificates = [
      'sha256/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=',
      'sha256/BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=',
    ];

    final certHash = sha256.convert(utf8.encode(certificate)).toString();
    return validCertificates.contains('sha256/$certHash');
  }
}
```

### 2. API Security

```dart
// lib/core/network/api_security.dart
class ApiSecurity {
  static Map<String, String> getSecureHeaders() {
    return {
      'X-Api-Key': const String.fromEnvironment('API_KEY'),
      'X-Device-Id': DeviceInfo.deviceId,
      'X-Request-Time': DateTime.now().toIso8601String(),
    };
  }

  static String generateRequestSignature(
    String method,
    String path,
    Map<String, dynamic> params,
  ) {
    final key = const String.fromEnvironment('API_SECRET');
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    
    final data = '$method$path${json.encode(params)}$timestamp';
    final hmac = Hmac(sha256, utf8.encode(key));
    return base64.encode(hmac.convert(utf8.encode(data)).bytes);
  }
}
```

## Code Security

### 1. Code Obfuscation

```yaml
# android/app/build.gradle
android {
    buildTypes {
        release {
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
}
```

### 2. Secure Configuration

```dart
// lib/core/config/secure_config.dart
class SecureConfig {
  static const apiKey = String.fromEnvironment('API_KEY');
  static const apiSecret = String.fromEnvironment('API_SECRET');

  static bool get isProduction {
    return const bool.fromEnvironment('dart.vm.product');
  }

  static String get apiBaseUrl {
    if (isProduction) {
      return 'https://api.production.com';
    }
    return 'https://api.staging.com';
  }
}
```

## Platform Security

### 1. Root/Jailbreak Detection

```dart
// lib/core/security/device_security.dart
class DeviceSecurity {
  static Future<bool> isDeviceSecure() async {
    if (Platform.isAndroid) {
      return await _checkRootAndroid();
    }
    if (Platform.isIOS) {
      return await _checkJailbreakIOS();
    }
    return true;
  }

  static Future<bool> _checkRootAndroid() async {
    try {
      const paths = [
        '/system/app/Superuser.apk',
        '/system/xbin/su',
        '/system/bin/su',
      ];

      for (final path in paths) {
        if (await File(path).exists()) {
          return false;
        }
      }
      return true;
    } catch (e) {
      return true;
    }
  }

  static Future<bool> _checkJailbreakIOS() async {
    try {
      const paths = [
        '/Applications/Cydia.app',
        '/Library/MobileSubstrate/MobileSubstrate.dylib',
        '/bin/bash',
        '/usr/sbin/sshd',
        '/etc/apt',
      ];

      for (final path in paths) {
        if (await File(path).exists()) {
          return false;
        }
      }
      return true;
    } catch (e) {
      return true;
    }
  }
}
```

### 2. App Protection

```dart
// lib/core/security/app_protection.dart
class AppProtection {
  static Future<void> initializeAppProtection() async {
    if (!await DeviceSecurity.isDeviceSecure()) {
      throw SecurityException('Device is not secure');
    }

    if (await _isRunningInEmulator()) {
      throw SecurityException('Running in emulator');
    }

    await _enableScreenProtection();
  }

  static Future<bool> _isRunningInEmulator() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      return androidInfo.isPhysicalDevice == false;
    }
    if (Platform.isIOS) {
      final iosInfo = await DeviceInfoPlugin().iosInfo;
      return iosInfo.isPhysicalDevice == false;
    }
    return false;
  }

  static Future<void> _enableScreenProtection() async {
    await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
  }
}
```

## Best Practices

1. **Data Protection**
   - Encrypt sensitive data
   - Use secure storage
   - Implement certificate pinning

2. **Authentication**
   - Implement token refresh
   - Use biometric when available
   - Handle session expiry

3. **Code Security**
   - Enable code obfuscation
   - Use environment variables
   - Implement proguard rules

4. **Network Security**
   - Use HTTPS only
   - Implement request signing
   - Validate certificates

## Security Checklist

- [ ] Implement SSL pinning
- [ ] Enable code obfuscation
- [ ] Secure local storage
- [ ] Implement authentication
- [ ] Add biometric support
- [ ] Check for root/jailbreak
- [ ] Encrypt sensitive data
- [ ] Secure API communication
- [ ] Handle session management
- [ ] Implement logging security

## Next Steps

1. Read the [Contributing Guide](11-contributing.md)
2. Check the [Future Features](12-future-features.md)
3. Review the [Troubleshooting Guide](13-troubleshooting.md)

---

Next: [Contributing Guide](11-contributing.md)
