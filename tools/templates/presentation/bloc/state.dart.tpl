import 'package:equatable/equatable.dart';
import '../../domain/entities/feature_name.dart';

abstract class FeatureNameState extends Equatable {
  const FeatureNameState();

  @override
  List<Object?> get props => [];
}

class FeatureNameInitial extends FeatureNameState {}

class FeatureNameLoading extends FeatureNameState {}

class FeatureNamesLoaded extends FeatureNameState {
  final List<FeatureName> featureNames;

  const FeatureNamesLoaded(this.featureNames);

  @override
  List<Object?> get props => [featureNames];
}

class FeatureNameLoaded extends FeatureNameState {
  final FeatureName featureName;

  const FeatureNameLoaded(this.featureName);

  @override
  List<Object?> get props => [featureName];
}

class FeatureNameError extends FeatureNameState {
  final String message;

  const FeatureNameError(this.message);

  @override
  List<Object?> get props => [message];
}
