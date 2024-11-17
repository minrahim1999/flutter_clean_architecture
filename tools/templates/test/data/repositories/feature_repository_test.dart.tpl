import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:example/core/error/exceptions.dart';
import 'package:example/core/error/failures.dart';
import 'package:example/core/network/network_info.dart';
import 'package:example/features/feature_name/data/datasources/feature_name_local_data_source.dart';
import 'package:example/features/feature_name/data/datasources/feature_name_remote_data_source.dart';
import 'package:example/features/feature_name/data/models/feature_name_model.dart';
import 'package:example/features/feature_name/data/repositories/feature_name_repository_impl.dart';
import 'package:example/features/feature_name/domain/entities/feature_name.dart';

class MockRemoteDataSource extends Mock implements FeatureNameRemoteDataSource {}
class MockLocalDataSource extends Mock implements FeatureNameLocalDataSource {}
class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late FeatureNameRepositoryImpl repository;
  late MockRemoteDataSource mockRemoteDataSource;
  late MockLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockRemoteDataSource();
    mockLocalDataSource = MockLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = FeatureNameRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  void runTestsOnline(Function body) {
    group('device is online', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      body();
    });
  }

  void runTestsOffline(Function body) {
    group('device is offline', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      body();
    });
  }

  group('getFeatureName', () {
    final tFeatureNameModel = FeatureNameModel(
      id: '1',
      name: 'Test Feature',
    );
    final FeatureName tFeatureName = tFeatureNameModel;

    runTestsOnline(() {
      test(
        'should return remote data when the call to remote data source is successful',
        () async {
          // Arrange
          when(mockRemoteDataSource.getFeatureName())
              .thenAnswer((_) async => tFeatureNameModel);

          // Act
          final result = await repository.getFeatureName();

          // Assert
          verify(mockRemoteDataSource.getFeatureName());
          expect(result, equals(Right(tFeatureName)));
        },
      );

      test(
        'should cache the data locally when the call to remote data source is successful',
        () async {
          // Arrange
          when(mockRemoteDataSource.getFeatureName())
              .thenAnswer((_) async => tFeatureNameModel);

          // Act
          await repository.getFeatureName();

          // Assert
          verify(mockRemoteDataSource.getFeatureName());
          verify(mockLocalDataSource.cacheFeatureName(tFeatureNameModel));
        },
      );

      test(
        'should return server failure when the call to remote data source is unsuccessful',
        () async {
          // Arrange
          when(mockRemoteDataSource.getFeatureName())
              .thenThrow(ServerException());

          // Act
          final result = await repository.getFeatureName();

          // Assert
          verify(mockRemoteDataSource.getFeatureName());
          verifyZeroInteractions(mockLocalDataSource);
          expect(result, equals(Left(ServerFailure())));
        },
      );
    });

    runTestsOffline(() {
      test(
        'should return last locally cached data when the cached data is present',
        () async {
          // Arrange
          when(mockLocalDataSource.getLastFeatureName())
              .thenAnswer((_) async => tFeatureNameModel);

          // Act
          final result = await repository.getFeatureName();

          // Assert
          verifyZeroInteractions(mockRemoteDataSource);
          verify(mockLocalDataSource.getLastFeatureName());
          expect(result, equals(Right(tFeatureName)));
        },
      );

      test(
        'should return CacheFailure when there is no cached data present',
        () async {
          // Arrange
          when(mockLocalDataSource.getLastFeatureName())
              .thenThrow(CacheException());

          // Act
          final result = await repository.getFeatureName();

          // Assert
          verifyZeroInteractions(mockRemoteDataSource);
          verify(mockLocalDataSource.getLastFeatureName());
          expect(result, equals(Left(CacheFailure())));
        },
      );
    });
  });
}
