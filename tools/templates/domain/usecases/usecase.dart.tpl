import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/feature_name_repository.dart';
import '../entities/feature_name.dart';

class GetFeatureNames implements UseCase<List<FeatureName>, PaginationParams> {
  final FeatureNameRepository repository;

  GetFeatureNames(this.repository);

  @override
  Future<Either<Failure, List<FeatureName>>> call(PaginationParams params) async {
    return await repository.getFeatureNames(page: params.page);
  }
}

class GetFeatureNameById implements UseCase<FeatureName, String> {
  final FeatureNameRepository repository;

  GetFeatureNameById(this.repository);

  @override
  Future<Either<Failure, FeatureName>> call(String id) async {
    return await repository.getFeatureNameById(id);
  }
}

class PaginationParams {
  final int page;

  const PaginationParams({this.page = 1});
}
