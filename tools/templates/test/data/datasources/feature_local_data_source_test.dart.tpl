import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:example/core/error/exceptions.dart';
import 'package:example/core/database/database_service.dart';
import 'package:example/features/feature_name/data/datasources/feature_name_local_data_source.dart';
import 'package:example/features/feature_name/data/models/feature_name_model.dart';

class MockDatabaseService extends Mock implements DatabaseService {}

void main() {
  late FeatureNameLocalDataSourceImpl dataSource;
  late MockDatabaseService mockDatabaseService;

  setUp(() {
    mockDatabaseService = MockDatabaseService();
    dataSource = FeatureNameLocalDataSourceImpl(databaseService: mockDatabaseService);
  });

  group('getFeatureNames', () {
    final tFeatureNameModels = [
      FeatureNameModel(id: '1', name: 'Test 1'),
      FeatureNameModel(id: '2', name: 'Test 2'),
    ];

    test('should return FeatureNames from database when they exist', () async {
      // Arrange
      when(mockDatabaseService.getAll('feature_names'))
          .thenAnswer((_) async => tFeatureNameModels);

      // Act
      final result = await dataSource.getFeatureNames();

      // Assert
      verify(mockDatabaseService.getAll('feature_names'));
      expect(result, equals(tFeatureNameModels));
    });

    test('should throw a CacheException when there is no cached data', () async {
      // Arrange
      when(mockDatabaseService.getAll('feature_names'))
          .thenThrow(Exception());

      // Act
      final call = dataSource.getFeatureNames;

      // Assert
      expect(() => call(), throwsA(isA<CacheException>()));
    });
  });

  group('getFeatureNameById', () {
    final tId = '1';
    final tFeatureNameModel = FeatureNameModel(id: tId, name: 'Test 1');

    test('should return FeatureName from database when it exists', () async {
      // Arrange
      when(mockDatabaseService.get('feature_names', tId))
          .thenAnswer((_) async => tFeatureNameModel);

      // Act
      final result = await dataSource.getFeatureNameById(tId);

      // Assert
      verify(mockDatabaseService.get('feature_names', tId));
      expect(result, equals(tFeatureNameModel));
    });

    test('should throw a CacheException when the data does not exist', () async {
      // Arrange
      when(mockDatabaseService.get('feature_names', tId))
          .thenThrow(Exception());

      // Act
      final call = () => dataSource.getFeatureNameById(tId);

      // Assert
      expect(call, throwsA(isA<CacheException>()));
    });
  });

  group('cacheFeatureNames', () {
    final tFeatureNameModels = [
      FeatureNameModel(id: '1', name: 'Test 1'),
      FeatureNameModel(id: '2', name: 'Test 2'),
    ];

    test('should call DatabaseService to cache the data', () async {
      // Arrange
      when(mockDatabaseService.saveAll('feature_names', any))
          .thenAnswer((_) async => true);

      // Act
      await dataSource.cacheFeatureNames(tFeatureNameModels);

      // Assert
      verify(mockDatabaseService.saveAll('feature_names', tFeatureNameModels));
    });

    test('should throw a CacheException when caching fails', () async {
      // Arrange
      when(mockDatabaseService.saveAll('feature_names', any))
          .thenThrow(Exception());

      // Act
      final call = () => dataSource.cacheFeatureNames(tFeatureNameModels);

      // Assert
      expect(call, throwsA(isA<CacheException>()));
    });
  });

  group('cacheFeatureName', () {
    final tFeatureNameModel = FeatureNameModel(id: '1', name: 'Test 1');

    test('should call DatabaseService to cache the single item', () async {
      // Arrange
      when(mockDatabaseService.save('feature_names', tFeatureNameModel.id, any))
          .thenAnswer((_) async => true);

      // Act
      await dataSource.cacheFeatureName(tFeatureNameModel);

      // Assert
      verify(mockDatabaseService.save('feature_names', tFeatureNameModel.id, tFeatureNameModel));
    });

    test('should throw a CacheException when caching fails', () async {
      // Arrange
      when(mockDatabaseService.save('feature_names', tFeatureNameModel.id, any))
          .thenThrow(Exception());

      // Act
      final call = () => dataSource.cacheFeatureName(tFeatureNameModel);

      // Assert
      expect(call, throwsA(isA<CacheException>()));
    });
  });

  group('removeFeatureName', () {
    final tId = '1';

    test('should call DatabaseService to remove the item', () async {
      // Arrange
      when(mockDatabaseService.delete('feature_names', tId))
          .thenAnswer((_) async => true);

      // Act
      final result = await dataSource.removeFeatureName(tId);

      // Assert
      verify(mockDatabaseService.delete('feature_names', tId));
      expect(result, equals(true));
    });

    test('should throw a CacheException when removal fails', () async {
      // Arrange
      when(mockDatabaseService.delete('feature_names', tId))
          .thenThrow(Exception());

      // Act
      final call = () => dataSource.removeFeatureName(tId);

      // Assert
      expect(call, throwsA(isA<CacheException>()));
    });
  });

  group('clearFeatureNames', () {
    test('should call DatabaseService to clear all items', () async {
      // Arrange
      when(mockDatabaseService.clear('feature_names'))
          .thenAnswer((_) async => true);

      // Act
      final result = await dataSource.clearFeatureNames();

      // Assert
      verify(mockDatabaseService.clear('feature_names'));
      expect(result, equals(true));
    });

    test('should throw a CacheException when clearing fails', () async {
      // Arrange
      when(mockDatabaseService.clear('feature_names'))
          .thenThrow(Exception());

      // Act
      final call = () => dataSource.clearFeatureNames();

      // Assert
      expect(call, throwsA(isA<CacheException>()));
    });
  });
}
