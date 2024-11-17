import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/repositories/feature_name_repository.dart';
import '../datasources/feature_name_local_data_source.dart';
import '../datasources/feature_name_remote_data_source.dart';
import '../models/feature_name_model.dart';

class FeatureNameRepositoryImpl implements FeatureNameRepository {
  final FeatureNameRemoteDataSource remoteDataSource;
  final FeatureNameLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  FeatureNameRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<FeatureNameModel>>> getFeatureNames({int page = 1}) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteFeatureNames = await remoteDataSource.getFeatureNames(page: page);
        await localDataSource.cacheFeatureNameList(remoteFeatureNames);
        return Right(remoteFeatureNames);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      try {
        final localFeatureNames = await localDataSource.getFeatureNameList(page: page);
        return Right(localFeatureNames);
      } on CacheException {
        return Left(CacheFailure());
      }
    }
  }

  @override
  Future<Either<Failure, FeatureNameModel>> getFeatureNameById(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteFeatureName = await remoteDataSource.getFeatureNameById(id);
        await localDataSource.cacheFeatureName(remoteFeatureName);
        return Right(remoteFeatureName);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      try {
        final localFeatureName = await localDataSource.getFeatureNameById(id);
        return Right(localFeatureName);
      } on CacheException {
        return Left(CacheFailure());
      }
    }
  }
}
