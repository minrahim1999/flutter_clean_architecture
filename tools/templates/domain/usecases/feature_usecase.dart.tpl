import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/feature_entity.dart';
import '../repositories/feature_repository.dart';

class GetFeaturesUseCase implements UseCase<List<FeatureEntity>, GetFeaturesParams> {
  final FeatureRepository repository;

  GetFeaturesUseCase(this.repository);

  @override
  Future<Either<Failure, List<FeatureEntity>>> call(GetFeaturesParams params) {
    return repository.getFeatures(page: params.page);
  }
}

class GetFeaturesParams extends Equatable {
  final int page;

  const GetFeaturesParams({
    this.page = 1,
  });

  @override
  List<Object?> get props => [page];
}
