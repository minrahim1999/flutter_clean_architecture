import 'package:equatable/equatable.dart';

abstract class FeatureNameEvent extends Equatable {
  const FeatureNameEvent();

  @override
  List<Object?> get props => [];
}

class GetFeatureNamesEvent extends FeatureNameEvent {
  final int page;

  const GetFeatureNamesEvent({this.page = 1});

  @override
  List<Object?> get props => [page];
}

class GetFeatureNameByIdEvent extends FeatureNameEvent {
  final String id;

  const GetFeatureNameByIdEvent(this.id);

  @override
  List<Object?> get props => [id];
}
