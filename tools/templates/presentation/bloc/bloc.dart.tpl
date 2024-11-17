import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_feature_name_usecase.dart';
import 'feature_name_event.dart';
import 'feature_name_state.dart';

class FeatureNameBloc extends Bloc<FeatureNameEvent, FeatureNameState> {
  final GetFeatureNames getFeatureNames;
  final GetFeatureNameById getFeatureNameById;

  FeatureNameBloc({
    required this.getFeatureNames,
    required this.getFeatureNameById,
  }) : super(FeatureNameInitial()) {
    on<GetFeatureNamesEvent>(_onGetFeatureNames);
    on<GetFeatureNameByIdEvent>(_onGetFeatureNameById);
  }

  Future<void> _onGetFeatureNames(
    GetFeatureNamesEvent event,
    Emitter<FeatureNameState> emit,
  ) async {
    emit(FeatureNameLoading());
    final failureOrFeatureNames = await getFeatureNames(PaginationParams(page: event.page));
    emit(failureOrFeatureNames.fold(
      (failure) => FeatureNameError(_mapFailureToMessage(failure)),
      (featureNames) => FeatureNamesLoaded(featureNames),
    ));
  }

  Future<void> _onGetFeatureNameById(
    GetFeatureNameByIdEvent event,
    Emitter<FeatureNameState> emit,
  ) async {
    emit(FeatureNameLoading());
    final failureOrFeatureName = await getFeatureNameById(event.id);
    emit(failureOrFeatureName.fold(
      (failure) => FeatureNameError(_mapFailureToMessage(failure)),
      (featureName) => FeatureNameLoaded(featureName),
    ));
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Server Failure';
      case CacheFailure:
        return 'Cache Failure';
      default:
        return 'Unexpected Error';
    }
  }
}
