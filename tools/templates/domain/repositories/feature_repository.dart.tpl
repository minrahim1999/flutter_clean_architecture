import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/feature_entity.dart';

abstract class FeatureRepository {
  Future<Either<Failure, List<FeatureEntity>>> getFeatures({int page = 1});
  Future<Either<Failure, FeatureEntity>> getFeatureById(String id);
  Future<Either<Failure, FeatureEntity>> createFeature(FeatureEntity feature);
  Future<Either<Failure, FeatureEntity>> updateFeature(FeatureEntity feature);
  Future<Either<Failure, bool>> deleteFeature(String id);
}
