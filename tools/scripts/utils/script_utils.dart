import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

/// Utility class for common script operations
class ScriptUtils {
  /// Gets the absolute path to the project root
  static String getProjectRoot() {
    final scriptFile = File(Platform.script.toFilePath());
    final toolsDir = scriptFile.parent.parent;
    return toolsDir.parent.absolute.path;
  }

  /// Runs flutter pub get
  static Future<void> getFlutterDependencies(String projectRoot) async {
    if (kDebugMode) {
      print('Getting dependencies...');
    }
    final result = await Process.run(
      'flutter',
      ['pub', 'get'],
      workingDirectory: projectRoot,
    );
    if (result.exitCode != 0) {
      throw 'Failed to get dependencies: ${result.stderr}';
    }
    if (kDebugMode) {
      print('✓ Dependencies updated\n');
    }
  }

  /// Runs build_runner if needed
  static Future<void> runBuildRunner(String projectRoot) async {
    final pubspecFile = File(path.join(projectRoot, 'pubspec.yaml'));
    if (!pubspecFile.existsSync()) {
      throw 'pubspec.yaml not found in $projectRoot';
    }

    final pubspecContent = await pubspecFile.readAsString();
    if (pubspecContent.contains('build_runner:')) {
      if (kDebugMode) {
        print('Running build_runner...');
      }
      final result = await Process.run(
        'flutter',
        ['pub', 'run', 'build_runner', 'build', '--delete-conflicting-outputs'],
        workingDirectory: projectRoot,
      );
      if (result.exitCode != 0) {
        throw 'Build runner failed: ${result.stderr}';
      }
      if (kDebugMode) {
        print('✓ Code generation completed\n');
      }
    }
  }

  /// Validates snake_case format
  static bool isValidSnakeCase(String name) {
    return RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(name);
  }

  /// Creates a directory if it doesn't exist
  static Future<void> createDirectoryIfNotExists(String path) async {
    final directory = Directory(path);
    if (!directory.existsSync()) {
      await directory.create(recursive: true);
    }
  }

  /// Checks if Flutter is installed and available
  static Future<void> validateFlutterInstallation() async {
    try {
      final result = await Process.run('flutter', ['--version']);
      if (result.exitCode != 0) {
        throw 'Flutter is not properly installed';
      }
    } catch (e) {
      throw 'Flutter is not installed or not in PATH: $e';
    }
  }

  /// Handles Windows-specific path issues
  static String normalizePath(String path) {
    return path.replaceAll('\\', '/');
  }

  /// Shows a progress indicator for long-running operations
  static void showProgress(String message) {
    stdout.write('$message...\r');
  }

  /// Updates progress
  static void updateProgress(String message, int progress, int total) {
    final percentage = ((progress / total) * 100).toStringAsFixed(1);
    stdout.write('$message... $percentage%\r');
  }

  /// Completes progress
  static void completeProgress(String message) {
    if (kDebugMode) {
      print('$message... Done ✓');
    }
  }
}
