import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:my_app/core/error/exceptions.dart';
import 'package:my_app/core/error/failures.dart';
import 'package:my_app/core/network/network_info.dart';
import 'package:my_app/features/feature_name/data/datasources/feature_name_local_data_source.dart';
import 'package:my_app/features/feature_name/data/datasources/feature_name_remote_data_source.dart';
import 'package:my_app/features/feature_name/data/models/feature_name_model.dart';
import 'package:my_app/features/feature_name/data/repositories/feature_name_repository_impl.dart';
import 'package:my_app/features/feature_name/domain/entities/feature_name.dart';

import 'feature_name_repository_impl_test.mocks.dart';

@GenerateMocks([
  FeatureNameRemoteDataSource,
  FeatureNameLocalDataSource,
  NetworkInfo,
])
void main() {
  late FeatureNameRepositoryImpl repository;
  late MockFeatureNameRemoteDataSource mockRemoteDataSource;
  late MockFeatureNameLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockFeatureNameRemoteDataSource();
    mockLocalDataSource = MockFeatureNameLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = FeatureNameRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  group('getFeatureNames', () {
    final tFeatureNameModel = FeatureNameModel(
      id: '1',
      title: 'Test FeatureName',
      description: 'Test Description',
    );
    final List<FeatureNameModel> tFeatureNameModels = [tFeatureNameModel];
    final List<FeatureName> tFeatureNames = tFeatureNameModels;

    test(
      'should check if the device is online',
      () async {
        // arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(mockRemoteDataSource.getFeatureNames())
            .thenAnswer((_) async => tFeatureNameModels);
        // act
        await repository.getFeatureNames();
        // assert
        verify(mockNetworkInfo.isConnected);
      },
    );

    group('device is online', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      test(
        'should return remote data when the call to remote data source is successful',
        () async {
          // arrange
          when(mockRemoteDataSource.getFeatureNames())
              .thenAnswer((_) async => tFeatureNameModels);
          // act
          final result = await repository.getFeatureNames();
          // assert
          verify(mockRemoteDataSource.getFeatureNames());
          expect(result, equals(Right(tFeatureNames)));
        },
      );

      test(
        'should cache the data locally when the call to remote data source is successful',
        () async {
          // arrange
          when(mockRemoteDataSource.getFeatureNames())
              .thenAnswer((_) async => tFeatureNameModels);
          // act
          await repository.getFeatureNames();
          // assert
          verify(mockRemoteDataSource.getFeatureNames());
          verify(mockLocalDataSource.cacheFeatureNames(tFeatureNameModels));
        },
      );

      test(
        'should return server failure when the call to remote data source is unsuccessful',
        () async {
          // arrange
          when(mockRemoteDataSource.getFeatureNames())
              .thenThrow(ServerException(message: 'Server Error'));
          // act
          final result = await repository.getFeatureNames();
          // assert
          verify(mockRemoteDataSource.getFeatureNames());
          verifyZeroInteractions(mockLocalDataSource);
          expect(result, equals(Left(ServerFailure('Server Error'))));
        },
      );
    });

    group('device is offline', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      test(
        'should return last locally cached data when the cached data is present',
        () async {
          // arrange
          when(mockLocalDataSource.getLastFeatureNames())
              .thenAnswer((_) async => tFeatureNameModels);
          // act
          final result = await repository.getFeatureNames();
          // assert
          verifyZeroInteractions(mockRemoteDataSource);
          verify(mockLocalDataSource.getLastFeatureNames());
          expect(result, equals(Right(tFeatureNames)));
        },
      );

      test(
        'should return CacheFailure when there is no cached data present',
        () async {
          // arrange
          when(mockLocalDataSource.getLastFeatureNames())
              .thenThrow(CacheException(message: 'No cached data'));
          // act
          final result = await repository.getFeatureNames();
          // assert
          verifyZeroInteractions(mockRemoteDataSource);
          verify(mockLocalDataSource.getLastFeatureNames());
          expect(result, equals(Left(CacheFailure('No cached data'))));
        },
      );
    });
  });
}
