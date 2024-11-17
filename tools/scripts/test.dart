import 'dart:io';

import 'package:flutter/foundation.dart';

import 'utils/script_utils.dart';

void main(List<String> args) async {
  try {
    await ScriptUtils.validateFlutterInstallation();
    final projectRoot = ScriptUtils.getProjectRoot();

    if (kDebugMode) {
      print('🧪 Running Flutter tests...\n');
    }

    // Get dependencies
    await ScriptUtils.getFlutterDependencies(projectRoot);

    // Run build runner if needed
    await ScriptUtils.runBuildRunner(projectRoot);

    // Run tests
    ScriptUtils.showProgress('Running tests');
    final testArgs = ['test', '--coverage'];

    // Add any additional arguments passed to the script
    if (args.isNotEmpty) {
      testArgs.addAll(args);
    }

    final testResult = await Process.run(
      'flutter',
      testArgs,
      workingDirectory: projectRoot,
    );

    if (kDebugMode) {
      print('\nTest Results:');
      print(testResult.stdout);
    }

    if (testResult.exitCode != 0) {
      if (kDebugMode) {
        print('\n❌ Tests failed:');
        print(testResult.stderr);
      }

      exit(1);
    }

    // Generate coverage report if lcov is installed
    try {
      final lcovResult = await Process.run('lcov', ['--version']);
      if (lcovResult.exitCode == 0) {
        ScriptUtils.showProgress('Generating coverage report');
        final genHtmlResult = await Process.run(
          'genhtml',
          ['coverage/lcov.info', '-o', 'coverage/html'],
          workingDirectory: projectRoot,
        );

        if (genHtmlResult.exitCode == 0) {
          ScriptUtils.completeProgress('Generating coverage report');
          if (kDebugMode) {
            print('✓ Coverage report generated at coverage/html/index.html\n');
          }
        } else {
          if (kDebugMode) {
            print('\n⚠️ Failed to generate HTML coverage report:');
            print(genHtmlResult.stderr);
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(
            '\nℹ️ lcov not installed. Skipping HTML coverage report generation.');
        print('To install lcov:');
        print('  • Ubuntu/Debian: sudo apt-get install lcov');
        print('  • macOS: brew install lcov');
        print('  • Windows: choco install lcov\n');
      }
    }

    if (kDebugMode) {
      print('✓ All tests passed successfully!\n');
    }
  } catch (e) {
    if (kDebugMode) {
      print('\n❌ Error running tests:');
      print(e.toString());
    }
    exit(1);
  }
}
