import 'dart:io';

import 'package:flutter/foundation.dart';

import 'utils/script_utils.dart';

void main(List<String> args) async {
  try {
    await ScriptUtils.validateFlutterInstallation();
    final projectRoot = ScriptUtils.getProjectRoot();

    if (kDebugMode) {
      print('🔨 Building Flutter application...\n');
    }

    // Clean build
    ScriptUtils.showProgress('Cleaning previous builds');
    final cleanResult = await Process.run(
      'flutter',
      ['clean'],
      workingDirectory: projectRoot,
    );
    if (cleanResult.exitCode != 0) {
      throw 'Clean failed: ${cleanResult.stderr}';
    }
    ScriptUtils.completeProgress('Cleaning previous builds');

    // Get dependencies
    await ScriptUtils.getFlutterDependencies(projectRoot);

    // Run build runner if needed
    await ScriptUtils.runBuildRunner(projectRoot);

    // Build the app
    ScriptUtils.showProgress('Building application');
    final buildArgs = ['build'];

    if (args.isNotEmpty) {
      buildArgs.addAll(args);
    } else {
      // Default to apk if no arguments provided
      buildArgs.add('apk');
      buildArgs.add('--release');
    }

    final result = await Process.run(
      'flutter',
      buildArgs,
      workingDirectory: projectRoot,
    );

    if (result.exitCode != 0) {
      throw 'Build failed: ${result.stderr}';
    }

    ScriptUtils.completeProgress('Building application');
    if (kDebugMode) {
      print('\nBuild output:');
      print(result.stdout);
    }
  } catch (e) {
    if (kDebugMode) {
      print('\n❌ Error during build:');
      print(e.toString());
    }

    exit(1);
  }
}
