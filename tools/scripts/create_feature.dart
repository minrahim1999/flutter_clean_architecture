import 'dart:io';
import 'dart:developer' as dev;

const bool debugMode = true;

void main(List<String> args) async {
  if (args.isEmpty) {
    if (debugMode) {
      dev.log('Please provide a feature name');
    }
    return;
  }

  final featureName = args[0];
  final featureNamePascal = toPascalCase(featureName);
  final projectName = await _getProjectName();

  try {
    const templatesDir = 'tools/templates';

    // Verify templates directory exists
    if (!Directory(templatesDir).existsSync()) {
      throw 'Templates directory not found at: $templatesDir';
    }

    if (Directory('lib/features/$featureName').existsSync()) {
      if (debugMode) {
        dev.log('\nRemoving existing feature...');
      }
      await _cleanupFeature(featureName, featureNamePascal);
    }

    // Create directories and files...
    await _createFeatureDirectories(featureName);
    await _createTestDirectories(featureName);
    await _createFeatureFiles(featureName, featureNamePascal, projectName);
    await _createTestFiles(featureName, featureNamePascal, projectName);

    // Update project files...
    if (debugMode) {
      dev.log('\nUpdating dependency injection...');
    }
    await _updateDependencyInjection(featureName, featureNamePascal);
    if (debugMode) {
      dev.log('Updating router...');
    }
    await _updateRouter(featureName, featureNamePascal);
    if (debugMode) {
      dev.log('Updating app...');
    }
    await _updateApp(featureName, featureNamePascal);

    if (debugMode) {
      dev.log('\n✨ Feature "$featureName" created successfully! ✨\n');
      dev.log('Next steps:');
      dev.log('1. Run "dart run build_runner build --delete-conflicting-outputs" to generate code');
      dev.log('2. Implement your feature-specific logic');
      dev.log('3. Add any additional routes if needed');
      dev.log('4. Run tests using "dart test"\n');
      dev.log('5. Run the app to test your new feature');
    }
  } catch (e) {
    if (debugMode) {
      dev.log('\n❌ Error: $e');
    }
  }
}

Future<String> _getProjectName() async {
  final pubspecFile = File('pubspec.yaml');
  if (!pubspecFile.existsSync()) {
    throw 'pubspec.yaml not found';
  }

  final content = await pubspecFile.readAsString();
  final nameMatch =
      RegExp(r'^name:\s+(.+)$', multiLine: true).firstMatch(content);
  if (nameMatch == null) {
    throw 'Project name not found in pubspec.yaml';
  }

  return nameMatch.group(1)!.trim();
}

Future<void> _createFeatureFiles(
    String featureName, String featureNamePascal, String projectName) async {
  if (debugMode) {
    dev.log('Creating feature files...');
  }
  const templatesDir = 'tools/templates';
  final targetDir = 'lib/features/$featureName';

  final files = {
    'data/datasources/${featureName}_remote_data_source.dart':
        'data/datasources/remote_data_source.dart.tpl',
    'data/datasources/${featureName}_local_data_source.dart':
        'data/datasources/local_data_source.dart.tpl',
    'data/models/${featureName}_model.dart': 'data/models/model.dart.tpl',
    'data/repositories/${featureName}_repository_impl.dart':
        'data/repositories/repository_impl.dart.tpl',
    'domain/entities/$featureName.dart': 'domain/entities/entity.dart.tpl',
    'domain/repositories/${featureName}_repository.dart':
        'domain/repositories/repository.dart.tpl',
    'domain/usecases/get_${featureName}_usecase.dart':
        'domain/usecases/usecase.dart.tpl',
    'presentation/bloc/${featureName}_bloc.dart':
        'presentation/bloc/bloc.dart.tpl',
    'presentation/bloc/${featureName}_event.dart':
        'presentation/bloc/event.dart.tpl',
    'presentation/bloc/${featureName}_state.dart':
        'presentation/bloc/state.dart.tpl',
    'presentation/pages/${featureName}_page.dart':
        'presentation/pages/page.dart.tpl',
    'presentation/widgets/${featureName}_content.dart':
        'presentation/widgets/content.dart.tpl',
    'presentation/widgets/${featureName}_loading.dart':
        'presentation/widgets/loading.dart.tpl',
    'presentation/widgets/${featureName}_error.dart':
        'presentation/widgets/error.dart.tpl',
  };

  var progress = 0;
  for (final entry in files.entries) {
    final targetFile = '$targetDir/${entry.key}';
    final templateFile = '$templatesDir/${entry.value}';

    if (debugMode) {
      dev.log('Creating ${entry.key} from template ${entry.value}');
    }
    await _createFileFromTemplate(
      templateFile,
      targetFile,
      featureName,
      featureNamePascal,
      projectName,
    );

    progress += 1;
    final percentage = (progress * 100.0 / files.length).toStringAsFixed(1);
    if (debugMode) {
      dev.log('Creating feature files... $percentage%');
    }
  }
  if (debugMode) {
    dev.log('Creating feature files... Done ✓');
  }
}

Future<void> _createTestFiles(
    String featureName, String featureNamePascal, String projectName) async {
  if (debugMode) {
    dev.log('Creating test files...');
  }
  const templatesDir = 'tools/templates/test';
  final targetDir = 'test/features/$featureName';

  final testFiles = {
    'presentation/bloc/${featureName}_bloc_test.dart': 'feature_bloc_test.dart.tpl',
    'data/repositories/${featureName}_repository_test.dart': 'feature_repository_test.dart.tpl',
    'data/datasources/${featureName}_remote_data_source_test.dart': 'data/datasources/remote_data_source_test.dart.tpl',
    'data/datasources/${featureName}_local_data_source_test.dart': 'data/datasources/local_data_source_test.dart.tpl',
    'data/models/${featureName}_model_test.dart': 'data/models/model_test.dart.tpl',
    'domain/repositories/${featureName}_repository_test.dart': 'domain/repositories/repository_test.dart.tpl',
    'domain/usecases/get_${featureName}_usecase_test.dart': 'domain/usecases/usecase_test.dart.tpl',
  };

  var progress = 0;
  for (final entry in testFiles.entries) {
    final targetFile = '$targetDir/${entry.key}';
    final templateFile = '$templatesDir/${entry.value}';

    if (!File(templateFile).existsSync()) {
      if (debugMode) {
        dev.log(
            '⚠ Warning: Template not found: ${File(templateFile).absolute.path}');
      }
      continue;
    }

    await _createFileFromTemplate(
      templateFile,
      targetFile,
      featureName,
      featureNamePascal,
      projectName,
    );

    progress += 1;
    final percentage = (progress * 100.0 / testFiles.length).toStringAsFixed(1);
    if (debugMode) {
      dev.log('Creating test files... $percentage%');
    }
  }
  if (debugMode) {
    dev.log('Creating test files... Done ✓');
  }
}

Future<void> _createFileFromTemplate(
  String templatePath,
  String targetPath,
  String featureName,
  String featureNamePascal,
  String projectName,
) async {
  final templateFile = File(templatePath);
  if (!templateFile.existsSync()) return;

  var content = await templateFile.readAsString();

  // Remove .tpl extension from target path if it exists
  if (targetPath.endsWith('.tpl')) {
    targetPath = targetPath.substring(0, targetPath.length - 4);
  }

  // Replace feature name placeholders
  content = content
      .replaceAll('%MODEL_NAME%', featureNamePascal)
      .replaceAll('%TABLE_NAME%', featureName.toLowerCase())
      .replaceAll('%CORE_ERROR_EXCEPTIONS_IMPORT%', 'package:$projectName/core/error/exceptions.dart')
      .replaceAll('%CORE_DATABASE_DATABASE_SERVICE_IMPORT%', 'package:$projectName/core/database/database_service.dart')
      .replaceAll('FeatureName', featureNamePascal)
      .replaceAll('feature_name', featureName)
      .replaceAll('featureName', toCamelCase(featureName))
      // Test-specific replacements
      .replaceAll('my_app', projectName)
      .replaceAll('package:my_app', 'package:$projectName')
      .replaceAll('GetFeatureNamesUseCase', 'Get${featureNamePascal}UseCase')
      .replaceAll('CreateFeatureNameUseCase', 'Create${featureNamePascal}UseCase')
      .replaceAll('UpdateFeatureNameUseCase', 'Update${featureNamePascal}UseCase')
      .replaceAll('DeleteFeatureNameUseCase', 'Delete${featureNamePascal}UseCase')
      .replaceAll('FeatureNameRemoteDataSource', '${featureNamePascal}RemoteDataSource')
      .replaceAll('FeatureNameLocalDataSource', '${featureNamePascal}LocalDataSource')
      .replaceAll('FeatureNameRepositoryImpl', '${featureNamePascal}RepositoryImpl')
      .replaceAll('FeatureNameRepository', '${featureNamePascal}Repository')
      .replaceAll('FeatureNameModel', '${featureNamePascal}Model')
      .replaceAll('FeatureNameBloc', '${featureNamePascal}Bloc');

  // Replace project name placeholder
  content = content.replaceAll('example', projectName);

  final targetFile = File(targetPath);
  await targetFile.create(recursive: true);
  await targetFile.writeAsString(content);
}

String toCamelCase(String text) {
  if (text.isEmpty) return text;
  final words = text.split(RegExp(r'[_\W]+'));
  final camelCase = words.first +
      words
          .skip(1)
          .map((word) => word[0].toUpperCase() + word.substring(1))
          .join('');
  return camelCase;
}

String toPascalCase(String text) {
  if (text.isEmpty) return text;
  final camelCase = toCamelCase(text);
  return camelCase[0].toUpperCase() + camelCase.substring(1);
}

Future<void> _updateDependencyInjection(
    String featureName, String featureNamePascal) async {
  final injectionFile = File('lib/core/di/injection_container.dart');
  if (!injectionFile.existsSync()) return;

  var content = injectionFile.readAsStringSync();

  // Remove existing feature imports
  final importRegex = RegExp(
    r"import '\.\.\/\.\.\/features\/.*?';(\r?\n|\r)",
    multiLine: true,
  );
  content = content.replaceAll(importRegex, '');

  // Remove existing feature registrations
  final registrationRegex = RegExp(
    r'\s+//\s+\w+\s+Feature\n.*?(?=\s+//|$)',
    multiLine: true,
    dotAll: true,
  );
  content = content.replaceAll(registrationRegex, '');

  // Add new imports
  final imports = '''
import '../../features/$featureName/data/datasources/${featureName}_local_data_source.dart';
import '../../features/$featureName/data/datasources/${featureName}_remote_data_source.dart';
import '../../features/$featureName/data/repositories/${featureName}_repository_impl.dart';
import '../../features/$featureName/domain/repositories/${featureName}_repository.dart';
import '../../features/$featureName/domain/usecases/get_${featureName}_usecase.dart';
import '../../features/$featureName/presentation/bloc/${featureName}_bloc.dart';''';

  // Add new registrations
  final registration = '''
  // $featureNamePascal Feature
  // Data Sources
  sl.registerLazySingleton<${featureNamePascal}LocalDataSource>(
    () => ${featureNamePascal}LocalDataSourceImpl(databaseService: sl()),
  );
  sl.registerLazySingleton<${featureNamePascal}RemoteDataSource>(
    () => ${featureNamePascal}RemoteDataSourceImpl(apiService: sl()),
  );

  // Repository
  sl.registerLazySingleton<${featureNamePascal}Repository>(
    () => ${featureNamePascal}RepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => Get${featureNamePascal}s(sl()));
  sl.registerLazySingleton(() => Get${featureNamePascal}ById(sl()));

  // BLoC
  sl.registerFactory(
    () => ${featureNamePascal}Bloc(
      get${featureNamePascal}s: sl(),
      get${featureNamePascal}ById: sl(),
    ),
  );''';

  // Find the last import and add new imports
  final lastImportIndex = content.lastIndexOf('import');
  final lastImportEndIndex = content.indexOf(';', lastImportIndex) + 1;
  content = content.replaceRange(
    lastImportEndIndex,
    lastImportEndIndex,
    '\n$imports',
  );

  // Find Features section and add new registrations
  final featuresSectionRegex = RegExp(r'//!\s*Features.*?}', dotAll: true);
  final match = featuresSectionRegex.firstMatch(content);
  
  if (match != null) {
    // Replace the Features section with new content
    content = content.replaceRange(
      match.start,
      match.end,
      '''//! Features
  // Add your feature dependencies here
$registration
}''',
    );
  } else {
    // If Features section not found, add before the last closing brace
    final lastBraceIndex = content.lastIndexOf('}');
    content = content.replaceRange(
      lastBraceIndex,
      lastBraceIndex,
      '''
  //! Features
  // Add your feature dependencies here
$registration
}''',
    );
  }

  // Clean up any double newlines
  content = content.replaceAll(RegExp(r'\n{3,}'), '\n\n');
  
  await injectionFile.writeAsString(content);
}

Future<void> _updateRouter(String featureName, String featureNamePascal) async {
  final routerFile = File('lib/core/router/app_router.dart');
  if (!routerFile.existsSync()) return;

  var content = routerFile.readAsStringSync();

  // Remove existing feature imports
  final importRegex = RegExp(
    r"import '.*?features/.*?';(\r?\n|\r)?",
    multiLine: true,
  );
  content = content.replaceAll(importRegex, '');

  // Remove existing route constants
  final constantRegex = RegExp(
    r'\s+static const String \w+ = .*?;(\r?\n|\r)?',
    multiLine: true,
  );
  content = content.replaceAll(constantRegex, '');

  // Add new import
  final import = "import '../../features/$featureName/presentation/pages/${featureName}_page.dart';";
  final lastImportIndex = content.lastIndexOf('import');
  final lastImportEndIndex = content.indexOf(';', lastImportIndex) + 1;
  content = content.replaceRange(
    lastImportEndIndex,
    lastImportEndIndex,
    '\n$import',
  );

  // Add route constants
  final constants = '''
  // Route paths as constants
  static const String home = '/';
  static const String $featureName = '/$featureName';
  static const String ${featureName}Detail = '/$featureName/:id';''';

  final routerConfigIndex = content.indexOf('// Router configuration');
  if (routerConfigIndex != -1) {
    content = content.replaceRange(
      content.lastIndexOf('// Route paths as constants'),
      routerConfigIndex,
      constants + '\n\n  ',
    );
  }

  // Remove existing routes
  final routesRegex = RegExp(
    r'routes: \[\s*(?:(?:GoRoute|//[^\n]*)\s*\([^)]*\)[^}]*},?\s*)*\s*\]',
    multiLine: true,
  );
  final routesMatch = routesRegex.firstMatch(content);
  if (routesMatch != null) {
    content = content.replaceRange(
      routesMatch.start,
      routesMatch.end,
      '''routes: [
      // Home route
      GoRoute(
        path: home,
        name: 'home',
        pageBuilder: (context, state) => _transitionPage(
          context: context,
          state: state,
          child: const HomePage(),
        ),
      ),
      
      // $featureNamePascal routes
      GoRoute(
        path: $featureName,
        name: '$featureName',
        pageBuilder: (context, state) => _transitionPage(
          context: context,
          state: state,
          child: const ${featureNamePascal}Page(),
        ),
        routes: [
          GoRoute(
            path: ':id',
            name: '$featureName-detail',
            pageBuilder: (context, state) {
              final id = state.pathParameters['id']!;
              return _transitionPage(
                context: context,
                state: state,
                child: ${featureNamePascal}Page(${featureName}Id: id),
              );
            },
          ),
        ],
      ),
    ]''',
    );
  }

  // Clean up any double newlines
  content = content.replaceAll(RegExp(r'\n{3,}'), '\n\n');

  await routerFile.writeAsString(content);
}

Future<void> _updateApp(String featureName, String featureNamePascal) async {
  final appFile = File('lib/app.dart');
  if (!appFile.existsSync()) return;

  var content = appFile.readAsStringSync();

  // Remove existing feature imports
  final importRegex = RegExp(
    r"import '.*?features/.*?';(\r?\n|\r)?",
    multiLine: true,
  );
  content = content.replaceAll(importRegex, '');

  // Add new import
  final import = "import 'features/$featureName/presentation/bloc/${featureName}_bloc.dart';";
  final lastImportIndex = content.lastIndexOf('import');
  final lastImportEndIndex = content.indexOf(';', lastImportIndex) + 1;
  content = content.replaceRange(
    lastImportEndIndex,
    lastImportEndIndex,
    '\n$import',
  );

  // Remove existing feature bloc providers
  final blocProviderRegex = RegExp(
    r'\s+BlocProvider<\w+Bloc>\([^)]*\),\s*',
    multiLine: true,
  );
  content = content.replaceAll(blocProviderRegex, '\n');

  // Add new BLoC provider
  final provider = '''
        // $featureNamePascal Bloc
        BlocProvider<${featureNamePascal}Bloc>(
          create: (context) => sl<${featureNamePascal}Bloc>(),
        ),''';

  // Find the providers section
  final providersMatch = RegExp(r'providers: \[\s*(.*?)\s*\],', dotAll: true).firstMatch(content);
  if (providersMatch != null) {
    content = content.replaceRange(
      providersMatch.start,
      providersMatch.end,
      '''providers: [
        // Core Blocs
        BlocProvider<ConnectionBloc>(
          create: (context) => sl<ConnectionBloc>(),
        ),
$provider
      ],''',
    );
  }

  // Clean up any double newlines
  content = content.replaceAll(RegExp(r'\n{3,}'), '\n\n');

  await appFile.writeAsString(content);
}

Future<void> _cleanupFeature(
    String featureName, String featureNamePascal) async {
  // Remove feature directory
  await Directory('lib/features/$featureName').delete(recursive: true);

  // Clean up router
  final routerFile = File('lib/core/router/app_router.dart');
  if (routerFile.existsSync()) {
    var content = routerFile.readAsStringSync();

    // Remove imports
    final featureImport = RegExp(
      r'''import '.*?features/''' + featureName + r'''/.*?;\n''',
      multiLine: true,
    );
    content = content.replaceAll(featureImport, '');

    // Remove routes
    final routePattern = RegExp(
      r'''      GoRoute\(\s*path: '/''' +
          featureName +
          r'''(?:/:\w+)?',\s*builder:[^}]+},\s*\),''',
      multiLine: true,
    );
    content = content.replaceAll(routePattern, '');

    await routerFile.writeAsString(content);
  }

  // Clean up dependency injection
  final injectionFile = File('lib/core/di/injection_container.dart');
  if (injectionFile.existsSync()) {
    var content = injectionFile.readAsStringSync();

    // Remove imports
    final featureImport = RegExp(
      r'''import '.*?features/''' + featureName + r'''/.*?;\n''',
      multiLine: true,
    );
    content = content.replaceAll(featureImport, '');

    // Remove registrations
    final registrationPattern = RegExp(
      r'''\s+// ''' + featureNamePascal + r''' Feature.*?(?=\s+//|\s*$)''',
      multiLine: true,
      dotAll: true,
    );
    content = content.replaceAll(registrationPattern, '');

    await injectionFile.writeAsString(content);
  }

  // Clean up app.dart
  final appFile = File('lib/app.dart');
  if (appFile.existsSync()) {
    var content = appFile.readAsStringSync();

    // Remove imports
    final featureImport = RegExp(
      r'''import '.*?features/''' + featureName + r'''/.*?;\n''',
      multiLine: true,
    );
    content = content.replaceAll(featureImport, '');

    // Remove BLoC provider
    final providerPattern = RegExp(
      r'''\s+BlocProvider<''' + featureNamePascal + r'''Bloc>\(.*?\),''',
      multiLine: true,
      dotAll: true,
    );
    content = content.replaceAll(providerPattern, '');

    await appFile.writeAsString(content);
  }

  if (debugMode) {
    dev.log('Cleanup completed.');
  }
}

Future<void> _createFeatureDirectories(String featureName) async {
  if (debugMode) {
    dev.log('Creating feature directories...');
  }
  final directories = [
    'data/datasources',
    'data/models',
    'data/repositories',
    'domain/entities',
    'domain/repositories',
    'domain/usecases',
    'presentation/bloc',
    'presentation/pages',
    'presentation/widgets',
  ];

  var progress = 0;
  for (final dir in directories) {
    final directory = Directory('lib/features/$featureName/$dir');
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }
    progress += 1;
    final percentage =
        (progress * 100.0 / directories.length).toStringAsFixed(1);
    if (debugMode) {
      dev.log('Creating feature directories... $percentage%');
    }
  }
  if (debugMode) {
    dev.log('Creating feature directories... Done ✓');
  }
}

Future<void> _createTestDirectories(String featureName) async {
  if (debugMode) {
    dev.log('Creating test directories...');
  }
  final directories = [
    'data/datasources',
    'data/models',
    'data/repositories',
    'domain/repositories',
    'domain/usecases',
    'presentation/bloc',
    'presentation/pages',
  ];

  var progress = 0;
  for (final dir in directories) {
    final directory = Directory('test/features/$featureName/$dir');
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }
    progress += 1;
    final percentage =
        (progress * 100.0 / directories.length).toStringAsFixed(1);
    if (debugMode) {
      dev.log('Creating test directories... $percentage%');
    }
  }
  if (debugMode) {
    dev.log('Creating test directories... Done ✓');
  }
}
