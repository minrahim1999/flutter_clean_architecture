import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/feature_name.dart';

abstract class FeatureNameRepository {
  Future<Either<Failure, List<FeatureName>>> getFeatureNames({int page = 1});
  Future<Either<Failure, FeatureName>> getFeatureNameById(String id);
}
