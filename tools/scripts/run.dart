import 'dart:io';

import 'package:flutter/foundation.dart';

import 'utils/script_utils.dart';

void main(List<String> args) async {
  try {
    await ScriptUtils.validateFlutterInstallation();
    final projectRoot = ScriptUtils.getProjectRoot();

    if (kDebugMode) {
      print('🚀 Running Flutter application...\n');
    }

    // Get dependencies
    await ScriptUtils.getFlutterDependencies(projectRoot);

    // Run build runner if needed
    await ScriptUtils.runBuildRunner(projectRoot);

    // Run the app
    ScriptUtils.showProgress('Starting application');
    final runArgs = ['run'];

    // Add any additional arguments passed to the script
    if (args.isNotEmpty) {
      runArgs.addAll(args);
    }

    // Start the Flutter process
    final process = await Process.start(
      'flutter',
      runArgs,
      workingDirectory: projectRoot,
      mode: ProcessStartMode.inheritStdio,
    );

    // Wait for the process to complete
    final exitCode = await process.exitCode;
    if (exitCode != 0) {
      throw 'Application exited with code: $exitCode';
    }
  } catch (e) {
    if (kDebugMode) {
      print('\n❌ Error running application:');
      print(e.toString());
    }

    exit(1);
  }
}
