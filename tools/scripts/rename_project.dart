import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

import 'utils/script_utils.dart';

void main(List<String> args) async {
  try {
    if (args.isEmpty) {
      if (kDebugMode) {
        print('Please provide a new project name');
        print('Usage: dart rename_project.dart <new_name>');
        print('Example: dart rename_project.dart my_awesome_app');
      }

      exit(1);
    }

    final newName = args[0].toLowerCase();
    if (!ScriptUtils.isValidSnakeCase(newName)) {
      if (kDebugMode) {
        print('Error: Project name should be in snake_case format');
        print('Example: my_awesome_app, flutter_project, mobile_app');
      }

      exit(1);
    }

    final projectRoot = ScriptUtils.getProjectRoot();

    if (kDebugMode) {
      print('🔄 Renaming project to "$newName"...\n');
    }

    // Read current project name from pubspec.yaml
    final pubspecFile = File(path.join(projectRoot, 'pubspec.yaml'));
    if (!pubspecFile.existsSync()) {
      throw 'pubspec.yaml not found in $projectRoot';
    }

    final pubspecContent = await pubspecFile.readAsString();
    final pubspec = loadYaml(pubspecContent);
    final currentName = pubspec['name'] as String;

    if (currentName == newName) {
      if (kDebugMode) {
        print('Project is already named "$newName"');
      }
      exit(0);
    }

    // Files to update
    final filesToUpdate = [
      'pubspec.yaml',
      'README.md',
      'android/app/build.gradle',
      'android/app/src/main/AndroidManifest.xml',
      'android/app/src/debug/AndroidManifest.xml',
      'android/app/src/profile/AndroidManifest.xml',
      'ios/Runner.xcodeproj/project.pbxproj',
      'ios/Runner/Info.plist',
      'web/index.html',
      'web/manifest.json',
      'linux/CMakeLists.txt',
      'macos/Runner/Configs/AppInfo.xcconfig',
      'windows/runner/main.cpp',
      'windows/runner/Runner.rc',
      '.idea/.name',
      '.idea/modules.xml',
    ];

    // Update each file
    ScriptUtils.showProgress('Updating project files');
    var fileCount = 0;
    for (final filePath in filesToUpdate) {
      final file = File(path.join(projectRoot, filePath));
      if (file.existsSync()) {
        var content = await file.readAsString();
        content = content.replaceAll(currentName, newName);
        await file.writeAsString(content);
        fileCount++;
        ScriptUtils.updateProgress(
            'Updating project files', fileCount, filesToUpdate.length);
      }
    }
    ScriptUtils.completeProgress('Updating project files');

    // Rename Android package
    final currentPackage = currentName.replaceAll('_', '');
    final newPackage = newName.replaceAll('_', '');

    final androidMainPath = path.join(
      projectRoot,
      'android/app/src/main/kotlin',
      currentPackage.split('.').join('/'),
    );

    if (Directory(androidMainPath).existsSync()) {
      ScriptUtils.showProgress('Updating Android package');
      final newAndroidPath = path.join(
        projectRoot,
        'android/app/src/main/kotlin',
        newPackage.split('.').join('/'),
      );

      // Create new directory structure
      await ScriptUtils.createDirectoryIfNotExists(
          path.dirname(newAndroidPath));

      // Move MainActivity.kt to new location
      final mainActivity = File(path.join(androidMainPath, 'MainActivity.kt'));
      if (mainActivity.existsSync()) {
        var content = await mainActivity.readAsString();
        content = content.replaceAll(
          'package $currentPackage',
          'package $newPackage',
        );
        await File(path.join(newAndroidPath, 'MainActivity.kt'))
            .writeAsString(content);
      }

      // Clean up old directory if empty
      final oldDir = Directory(androidMainPath);
      if (oldDir.existsSync() && oldDir.listSync().isEmpty) {
        await oldDir.delete(recursive: true);
      }
      ScriptUtils.completeProgress('Updating Android package');
    }

    if (kDebugMode) {
      print('\n✨ Project successfully renamed to "$newName"!\n');
      print('Next steps:');
      print('1. Run "flutter clean" to clean build files');
      print('2. Run "flutter pub get" to update dependencies');
      print('3. Update your version control system if needed');
    }
  } catch (e) {
    if (kDebugMode) {
      print('\n❌ Error renaming project:');
      print(e.toString());
    }

    exit(1);
  }
}
