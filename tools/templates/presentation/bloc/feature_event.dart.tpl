part of 'feature_bloc.dart';

import 'package:equatable/equatable.dart';
import '../../domain/entities/feature_name.dart';

abstract class FeatureEvent extends Equatable {
  const FeatureEvent();

  @override
  List<Object?> get props => [];
}

class LoadFeatures extends FeatureEvent {
  final int page;

  const LoadFeatures({this.page = 1});

  @override
  List<Object?> get props => [page];
}

class LoadFeatureNameById extends FeatureEvent {
  final String id;

  const LoadFeatureNameById({required this.id});

  @override
  List<Object?> get props => [id];
}

class CreateFeatureNameEvent extends FeatureEvent {
  final FeatureName featureName;

  const CreateFeatureNameEvent({required this.featureName});

  @override
  List<Object?> get props => [featureName];
}

class UpdateFeatureNameEvent extends FeatureEvent {
  final FeatureName featureName;

  const UpdateFeatureNameEvent({required this.featureName});

  @override
  List<Object?> get props => [featureName];
}

class DeleteFeatureNameEvent extends FeatureEvent {
  final String id;

  const DeleteFeatureNameEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

class RefreshFeatures extends FeatureEvent {}

class SearchFeatures extends FeatureEvent {
  final String query;

  const SearchFeatures(this.query);

  @override
  List<Object?> get props => [query];
}
