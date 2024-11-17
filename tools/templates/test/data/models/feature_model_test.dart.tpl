import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:example/core/error/exceptions.dart';
import 'package:example/features/feature_name/data/models/feature_name_model.dart';
import 'package:example/features/feature_name/domain/entities/feature_name.dart';

void main() {
  final tFeatureNameModel = FeatureNameModel(
    id: '1',
    name: 'Test Feature',
    description: 'Test Description',
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 2),
  );

  test('should be a subclass of FeatureName entity', () {
    // Assert
    expect(tFeatureNameModel, isA<FeatureName>());
  });

  group('fromJson', () {
    test('should return a valid model when the JSON data is valid', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'id': '1',
        'name': 'Test Feature',
        'description': 'Test Description',
        'created_at': '2024-01-01T00:00:00.000Z',
        'updated_at': '2024-01-02T00:00:00.000Z',
      };

      // Act
      final result = FeatureNameModel.fromJson(jsonMap);

      // Assert
      expect(result, tFeatureNameModel);
    });

    test('should throw a FormatException when the JSON data is invalid', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'id': null,
        'name': null,
        'description': null,
        'created_at': 'invalid-date',
        'updated_at': 'invalid-date',
      };

      // Act
      final call = () => FeatureNameModel.fromJson(jsonMap);

      // Assert
      expect(call, throwsA(isA<FormatException>()));
    });

    test('should handle missing optional fields', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'id': '1',
        'name': 'Test Feature',
      };

      // Act
      final result = FeatureNameModel.fromJson(jsonMap);

      // Assert
      expect(result.id, '1');
      expect(result.name, 'Test Feature');
      expect(result.description, isNull);
      expect(result.createdAt, isNull);
      expect(result.updatedAt, isNull);
    });
  });

  group('toJson', () {
    test('should return a JSON map containing all non-null fields', () {
      // Act
      final result = tFeatureNameModel.toJson();

      // Assert
      final expectedMap = {
        'id': '1',
        'name': 'Test Feature',
        'description': 'Test Description',
        'created_at': '2024-01-01T00:00:00.000Z',
        'updated_at': '2024-01-02T00:00:00.000Z',
      };
      expect(result, expectedMap);
    });

    test('should exclude null fields from JSON map', () {
      // Arrange
      final modelWithNulls = FeatureNameModel(
        id: '1',
        name: 'Test Feature',
      );

      // Act
      final result = modelWithNulls.toJson();

      // Assert
      final expectedMap = {
        'id': '1',
        'name': 'Test Feature',
      };
      expect(result, expectedMap);
      expect(result.containsKey('description'), isFalse);
      expect(result.containsKey('created_at'), isFalse);
      expect(result.containsKey('updated_at'), isFalse);
    });
  });

  group('copyWith', () {
    test('should return a new instance with updated values', () {
      // Act
      final result = tFeatureNameModel.copyWith(
        name: 'New Name',
        description: 'New Description',
      );

      // Assert
      expect(result.id, tFeatureNameModel.id);
      expect(result.name, 'New Name');
      expect(result.description, 'New Description');
      expect(result.createdAt, tFeatureNameModel.createdAt);
      expect(result.updatedAt, tFeatureNameModel.updatedAt);
    });

    test('should return same instance when no values are updated', () {
      // Act
      final result = tFeatureNameModel.copyWith();

      // Assert
      expect(result, tFeatureNameModel);
    });

    test('should handle null values in copyWith', () {
      // Act
      final result = tFeatureNameModel.copyWith(
        description: null,
        updatedAt: null,
      );

      // Assert
      expect(result.id, tFeatureNameModel.id);
      expect(result.name, tFeatureNameModel.name);
      expect(result.description, isNull);
      expect(result.createdAt, tFeatureNameModel.createdAt);
      expect(result.updatedAt, isNull);
    });
  });

  group('toString', () {
    test('should return a string representation of the model with all fields', () {
      // Act
      final result = tFeatureNameModel.toString();

      // Assert
      expect(
        result,
        'FeatureNameModel(id: 1, name: Test Feature, description: Test Description, createdAt: 2024-01-01 00:00:00.000, updatedAt: 2024-01-02 00:00:00.000)',
      );
    });

    test('should handle null fields in toString', () {
      // Arrange
      final modelWithNulls = FeatureNameModel(
        id: '1',
        name: 'Test Feature',
      );

      // Act
      final result = modelWithNulls.toString();

      // Assert
      expect(
        result,
        'FeatureNameModel(id: 1, name: Test Feature, description: null, createdAt: null, updatedAt: null)',
      );
    });
  });

  group('equality', () {
    test('should return true for the same model', () {
      // Arrange
      final model1 = FeatureNameModel(
        id: '1',
        name: 'Test Feature',
      );
      final model2 = FeatureNameModel(
        id: '1',
        name: 'Test Feature',
      );

      // Act & Assert
      expect(model1, equals(model2));
      expect(model1.hashCode, equals(model2.hashCode));
    });

    test('should return false for different models', () {
      // Arrange
      final model1 = FeatureNameModel(
        id: '1',
        name: 'Test Feature 1',
      );
      final model2 = FeatureNameModel(
        id: '2',
        name: 'Test Feature 2',
      );

      // Act & Assert
      expect(model1, isNot(equals(model2)));
      expect(model1.hashCode, isNot(equals(model2.hashCode)));
    });
  });
}
