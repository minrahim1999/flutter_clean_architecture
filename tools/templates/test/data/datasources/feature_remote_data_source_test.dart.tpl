import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:example/core/error/exceptions.dart';
import 'package:example/core/network/api_service.dart';
import 'package:example/features/feature_name/data/datasources/feature_name_remote_data_source.dart';
import 'package:example/features/feature_name/data/models/feature_name_model.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  late FeatureNameRemoteDataSourceImpl dataSource;
  late MockApiService mockApiService;

  setUp(() {
    mockApiService = MockApiService();
    dataSource = FeatureNameRemoteDataSourceImpl(apiService: mockApiService);
  });

  group('getFeatureNames', () {
    final tFeatureNameModel = FeatureNameModel(
      id: '1',
      name: 'Test Feature',
    );

    test('should return FeatureNames when the call is successful', () async {
      // Arrange
      final response = {
        'data': [
          {
            'id': '1',
            'name': 'Test Feature',
          }
        ]
      };
      when(mockApiService.get<Map<String, dynamic>>('/feature_names'))
          .thenAnswer((_) async => response);

      // Act
      final result = await dataSource.getFeatureNames();

      // Assert
      verify(mockApiService.get('/feature_names'));
      expect(result, equals([tFeatureNameModel]));
    });

    test('should throw a ServerException when the call is unsuccessful', () async {
      // Arrange
      when(mockApiService.get<Map<String, dynamic>>('/feature_names'))
          .thenThrow(Exception());

      // Act
      final call = dataSource.getFeatureNames;

      // Assert
      expect(() => call(), throwsA(isA<ServerException>()));
    });
  });

  group('getFeatureNameById', () {
    final tId = '1';
    final tFeatureNameModel = FeatureNameModel(
      id: tId,
      name: 'Test Feature',
    );

    test('should return FeatureName when the call is successful', () async {
      // Arrange
      final response = {
        'data': {
          'id': '1',
          'name': 'Test Feature',
        }
      };
      when(mockApiService.get<Map<String, dynamic>>('/feature_names/$tId'))
          .thenAnswer((_) async => response);

      // Act
      final result = await dataSource.getFeatureNameById(tId);

      // Assert
      verify(mockApiService.get('/feature_names/$tId'));
      expect(result, equals(tFeatureNameModel));
    });

    test('should throw a ServerException when the call is unsuccessful', () async {
      // Arrange
      when(mockApiService.get<Map<String, dynamic>>('/feature_names/$tId'))
          .thenThrow(Exception());

      // Act
      final call = () => dataSource.getFeatureNameById(tId);

      // Assert
      expect(call, throwsA(isA<ServerException>()));
    });
  });

  group('createFeatureName', () {
    final tFeatureNameModel = FeatureNameModel(
      id: '1',
      name: 'Test Feature',
    );

    test('should return FeatureName when the call is successful', () async {
      // Arrange
      final response = {
        'data': {
          'id': '1',
          'name': 'Test Feature',
        }
      };
      when(mockApiService.post<Map<String, dynamic>>(
        '/feature_names',
        body: anyNamed('body'),
      )).thenAnswer((_) async => response);

      // Act
      final result = await dataSource.createFeatureName(tFeatureNameModel);

      // Assert
      verify(mockApiService.post(
        '/feature_names',
        body: tFeatureNameModel.toJson(),
      ));
      expect(result, equals(tFeatureNameModel));
    });

    test('should throw a ServerException when the call is unsuccessful', () async {
      // Arrange
      when(mockApiService.post<Map<String, dynamic>>(
        '/feature_names',
        body: anyNamed('body'),
      )).thenThrow(Exception());

      // Act
      final call = () => dataSource.createFeatureName(tFeatureNameModel);

      // Assert
      expect(call, throwsA(isA<ServerException>()));
    });
  });

  group('updateFeatureName', () {
    final tFeatureNameModel = FeatureNameModel(
      id: '1',
      name: 'Test Feature',
    );

    test('should return FeatureName when the call is successful', () async {
      // Arrange
      final response = {
        'data': {
          'id': '1',
          'name': 'Test Feature',
        }
      };
      when(mockApiService.put<Map<String, dynamic>>(
        '/feature_names/${tFeatureNameModel.id}',
        body: anyNamed('body'),
      )).thenAnswer((_) async => response);

      // Act
      final result = await dataSource.updateFeatureName(tFeatureNameModel);

      // Assert
      verify(mockApiService.put(
        '/feature_names/${tFeatureNameModel.id}',
        body: tFeatureNameModel.toJson(),
      ));
      expect(result, equals(tFeatureNameModel));
    });

    test('should throw a ServerException when the call is unsuccessful', () async {
      // Arrange
      when(mockApiService.put<Map<String, dynamic>>(
        '/feature_names/${tFeatureNameModel.id}',
        body: anyNamed('body'),
      )).thenThrow(Exception());

      // Act
      final call = () => dataSource.updateFeatureName(tFeatureNameModel);

      // Assert
      expect(call, throwsA(isA<ServerException>()));
    });
  });

  group('deleteFeatureName', () {
    final tId = '1';

    test('should return true when the call is successful', () async {
      // Arrange
      when(mockApiService.delete<bool>(
        '/feature_names/$tId',
      )).thenAnswer((_) async => true);

      // Act
      final result = await dataSource.deleteFeatureName(tId);

      // Assert
      verify(mockApiService.delete('/feature_names/$tId'));
      expect(result, equals(true));
    });

    test('should throw a ServerException when the call is unsuccessful', () async {
      // Arrange
      when(mockApiService.delete<bool>(
        '/feature_names/$tId',
      )).thenThrow(Exception());

      // Act
      final call = () => dataSource.deleteFeatureName(tId);

      // Assert
      expect(call, throwsA(isA<ServerException>()));
    });
  });
}
