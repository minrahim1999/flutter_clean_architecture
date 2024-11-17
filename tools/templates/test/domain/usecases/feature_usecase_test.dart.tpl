import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:example/core/error/failures.dart';
import 'package:example/core/usecases/usecase.dart';
import 'package:example/features/feature_name/domain/entities/feature_name.dart';
import 'package:example/features/feature_name/domain/repositories/feature_name_repository.dart';
import 'package:example/features/feature_name/domain/usecases/get_feature_name_usecase.dart';
import 'package:example/features/feature_name/domain/usecases/create_feature_name_usecase.dart';
import 'package:example/features/feature_name/domain/usecases/update_feature_name_usecase.dart';
import 'package:example/features/feature_name/domain/usecases/delete_feature_name_usecase.dart';

class MockFeatureNameRepository extends Mock implements FeatureNameRepository {}

void main() {
  late MockFeatureNameRepository mockRepository;

  setUp(() {
    mockRepository = MockFeatureNameRepository();
  });

  final tFeatureName = FeatureName(
    id: '1',
    name: 'Test Feature',
    description: 'Test Description',
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 2),
  );

  group('GetFeatureNameUseCase', () {
    late GetFeatureNameUseCase usecase;

    setUp(() {
      usecase = GetFeatureNameUseCase(mockRepository);
    });

    test('should get FeatureName from the repository', () async {
      // Arrange
      when(mockRepository.getFeatureName())
          .thenAnswer((_) async => Right(tFeatureName));

      // Act
      final result = await usecase(NoParams());

      // Assert
      expect(result, Right(tFeatureName));
      verify(mockRepository.getFeatureName());
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ServerFailure when getting FeatureName fails with server error', () async {
      // Arrange
      when(mockRepository.getFeatureName())
          .thenAnswer((_) async => Left(ServerFailure()));

      // Act
      final result = await usecase(NoParams());

      // Assert
      expect(result, Left(ServerFailure()));
      verify(mockRepository.getFeatureName());
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return CacheFailure when getting FeatureName fails with cache error', () async {
      // Arrange
      when(mockRepository.getFeatureName())
          .thenAnswer((_) async => Left(CacheFailure()));

      // Act
      final result = await usecase(NoParams());

      // Assert
      expect(result, Left(CacheFailure()));
      verify(mockRepository.getFeatureName());
      verifyNoMoreInteractions(mockRepository);
    });
  });

  group('CreateFeatureNameUseCase', () {
    late CreateFeatureNameUseCase usecase;

    setUp(() {
      usecase = CreateFeatureNameUseCase(mockRepository);
    });

    test('should create FeatureName through the repository', () async {
      // Arrange
      when(mockRepository.createFeatureName(any))
          .thenAnswer((_) async => Right(tFeatureName));

      // Act
      final result = await usecase(CreateFeatureNameParams(featureName: tFeatureName));

      // Assert
      expect(result, Right(tFeatureName));
      verify(mockRepository.createFeatureName(tFeatureName));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ServerFailure when creating FeatureName fails', () async {
      // Arrange
      when(mockRepository.createFeatureName(any))
          .thenAnswer((_) async => Left(ServerFailure()));

      // Act
      final result = await usecase(CreateFeatureNameParams(featureName: tFeatureName));

      // Assert
      expect(result, Left(ServerFailure()));
      verify(mockRepository.createFeatureName(tFeatureName));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ValidationFailure when creating FeatureName with invalid data', () async {
      // Arrange
      final invalidFeatureName = FeatureName(
        id: '',
        name: '',
        description: '',
      );
      when(mockRepository.createFeatureName(any))
          .thenAnswer((_) async => Left(ValidationFailure()));

      // Act
      final result = await usecase(CreateFeatureNameParams(featureName: invalidFeatureName));

      // Assert
      expect(result, Left(ValidationFailure()));
      verify(mockRepository.createFeatureName(invalidFeatureName));
      verifyNoMoreInteractions(mockRepository);
    });
  });

  group('UpdateFeatureNameUseCase', () {
    late UpdateFeatureNameUseCase usecase;

    setUp(() {
      usecase = UpdateFeatureNameUseCase(mockRepository);
    });

    test('should update FeatureName through the repository', () async {
      // Arrange
      when(mockRepository.updateFeatureName(any))
          .thenAnswer((_) async => Right(tFeatureName));

      // Act
      final result = await usecase(UpdateFeatureNameParams(featureName: tFeatureName));

      // Assert
      expect(result, Right(tFeatureName));
      verify(mockRepository.updateFeatureName(tFeatureName));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ServerFailure when updating FeatureName fails', () async {
      // Arrange
      when(mockRepository.updateFeatureName(any))
          .thenAnswer((_) async => Left(ServerFailure()));

      // Act
      final result = await usecase(UpdateFeatureNameParams(featureName: tFeatureName));

      // Assert
      expect(result, Left(ServerFailure()));
      verify(mockRepository.updateFeatureName(tFeatureName));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return NotFoundFailure when updating non-existent FeatureName', () async {
      // Arrange
      when(mockRepository.updateFeatureName(any))
          .thenAnswer((_) async => Left(NotFoundFailure()));

      // Act
      final result = await usecase(UpdateFeatureNameParams(featureName: tFeatureName));

      // Assert
      expect(result, Left(NotFoundFailure()));
      verify(mockRepository.updateFeatureName(tFeatureName));
      verifyNoMoreInteractions(mockRepository);
    });
  });

  group('DeleteFeatureNameUseCase', () {
    late DeleteFeatureNameUseCase usecase;

    setUp(() {
      usecase = DeleteFeatureNameUseCase(mockRepository);
    });

    test('should delete FeatureName through the repository', () async {
      // Arrange
      when(mockRepository.deleteFeatureName(any))
          .thenAnswer((_) async => const Right(true));

      // Act
      final result = await usecase(DeleteFeatureNameParams(id: tFeatureName.id));

      // Assert
      expect(result, const Right(true));
      verify(mockRepository.deleteFeatureName(tFeatureName.id));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ServerFailure when deleting FeatureName fails', () async {
      // Arrange
      when(mockRepository.deleteFeatureName(any))
          .thenAnswer((_) async => Left(ServerFailure()));

      // Act
      final result = await usecase(DeleteFeatureNameParams(id: tFeatureName.id));

      // Assert
      expect(result, Left(ServerFailure()));
      verify(mockRepository.deleteFeatureName(tFeatureName.id));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return NotFoundFailure when deleting non-existent FeatureName', () async {
      // Arrange
      when(mockRepository.deleteFeatureName(any))
          .thenAnswer((_) async => Left(NotFoundFailure()));

      // Act
      final result = await usecase(DeleteFeatureNameParams(id: 'non-existent-id'));

      // Assert
      expect(result, Left(NotFoundFailure()));
      verify(mockRepository.deleteFeatureName('non-existent-id'));
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
