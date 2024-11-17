part of 'feature_bloc.dart';

import 'package:equatable/equatable.dart';
import '../../domain/entities/feature_name.dart';

abstract class FeatureState extends Equatable {
  const FeatureState();
  
  @override
  List<Object?> get props => [];
}

class FeatureInitial extends FeatureState {}

class FeatureLoading extends FeatureState {}

class FeatureLoaded extends FeatureState {
  final List<FeatureEntity> features;
  final bool hasReachedMax;
  final int currentPage;

  const FeatureLoaded({
    required this.features,
    this.hasReachedMax = false,
    this.currentPage = 1,
  });

  @override
  List<Object?> get props => [features, hasReachedMax, currentPage];

  FeatureLoaded copyWith({
    List<FeatureEntity>? features,
    bool? hasReachedMax,
    int? currentPage,
  }) {
    return FeatureLoaded(
      features: features ?? this.features,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class FeatureError extends FeatureState {
  final String message;

  const FeatureError(this.message);

  @override
  List<Object?> get props => [message];
}

abstract class FeatureNameState extends Equatable {
  const FeatureNameState();

  @override
  List<Object?> get props => [];
}

class FeatureNameInitial extends FeatureNameState {}

class FeatureNameLoading extends FeatureNameState {}

class FeatureNameLoaded extends FeatureNameState {
  final FeatureName featureName;

  const FeatureNameLoaded({required this.featureName});

  @override
  List<Object?> get props => [featureName];
}

class FeatureNamesLoaded extends FeatureNameState {
  final List<FeatureName> featureNames;
  final bool hasReachedMax;
  final int currentPage;

  const FeatureNamesLoaded({
    required this.featureNames,
    this.hasReachedMax = false,
    this.currentPage = 1,
  });

  FeatureNamesLoaded copyWith({
    List<FeatureName>? featureNames,
    bool? hasReachedMax,
    int? currentPage,
  }) {
    return FeatureNamesLoaded(
      featureNames: featureNames ?? this.featureNames,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [featureNames, hasReachedMax, currentPage];
}

class FeatureNameCreated extends FeatureNameState {
  final FeatureName featureName;

  const FeatureNameCreated({required this.featureName});

  @override
  List<Object?> get props => [featureName];
}

class FeatureNameUpdated extends FeatureNameState {
  final FeatureName featureName;

  const FeatureNameUpdated({required this.featureName});

  @override
  List<Object?> get props => [featureName];
}

class FeatureNameDeleted extends FeatureNameState {
  final String id;

  const FeatureNameDeleted({required this.id});

  @override
  List<Object?> get props => [id];
}

class FeatureNameError extends FeatureNameState {
  final String message;

  const FeatureNameError({required this.message});

  @override
  List<Object?> get props => [message];
}
