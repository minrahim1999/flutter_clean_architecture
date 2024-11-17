import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/feature_entity.dart';
import '../../domain/repositories/feature_repository.dart';
import '../datasources/feature_local_data_source.dart';
import '../datasources/feature_remote_data_source.dart';
import '../models/feature_model.dart';

class FeatureRepositoryImpl implements FeatureRepository {
  final FeatureRemoteDataSource remoteDataSource;
  final FeatureLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  FeatureRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<FeatureEntity>>> getFeatures({int page = 1}) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteFeatures = await remoteDataSource.getFeatures(page: page);
        await localDataSource.cacheFeatures(remoteFeatures);
        return Right(remoteFeatures);
      } on ServerException {
        try {
          final localFeatures = await localDataSource.getFeatures(page: page);
          return Right(localFeatures);
        } on CacheException {
          return Left(CacheFailure());
        }
      }
    } else {
      try {
        final localFeatures = await localDataSource.getFeatures(page: page);
        return Right(localFeatures);
      } on CacheException {
        return Left(CacheFailure());
      }
    }
  }

  @override
  Future<Either<Failure, FeatureEntity>> getFeatureById(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteFeature = await remoteDataSource.getFeatureById(id);
        await localDataSource.cacheFeature(remoteFeature);
        return Right(remoteFeature);
      } on ServerException {
        try {
          final localFeature = await localDataSource.getFeatureById(id);
          return Right(localFeature);
        } on CacheException {
          return Left(CacheFailure());
        }
      }
    } else {
      try {
        final localFeature = await localDataSource.getFeatureById(id);
        return Right(localFeature);
      } on CacheException {
        return Left(CacheFailure());
      }
    }
  }

  @override
  Future<Either<Failure, FeatureEntity>> createFeature(
    FeatureEntity feature,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final featureModel = FeatureModel.fromEntity(feature);
        final createdFeature = await remoteDataSource.createFeature(featureModel);
        await localDataSource.cacheFeature(createdFeature);
        return Right(createdFeature);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, FeatureEntity>> updateFeature(
    FeatureEntity feature,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final featureModel = FeatureModel.fromEntity(feature);
        final updatedFeature = await remoteDataSource.updateFeature(featureModel);
        await localDataSource.cacheFeature(updatedFeature);
        return Right(updatedFeature);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> deleteFeature(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.deleteFeature(id);
        if (result) {
          await localDataSource.deleteFeature(id);
        }
        return Right(result);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }
}
