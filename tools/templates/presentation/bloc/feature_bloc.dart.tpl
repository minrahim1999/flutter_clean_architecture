import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/feature_name.dart';
import '../../domain/usecases/get_feature_names_usecase.dart';
import '../../domain/usecases/get_feature_name_by_id_usecase.dart';
import '../../domain/usecases/create_feature_name_usecase.dart';
import '../../domain/usecases/update_feature_name_usecase.dart';
import '../../domain/usecases/delete_feature_name_usecase.dart';
import 'feature_name_event.dart';
import 'feature_name_state.dart';

// Events
abstract class FeatureNameEvent extends Equatable {
  const FeatureNameEvent();

  @override
  List<Object?> get props => [];
}

class LoadFeatureNames extends FeatureNameEvent {
  final int page;

  const LoadFeatureNames({this.page = 1});

  @override
  List<Object?> get props => [page];
}

class LoadFeatureNameById extends FeatureNameEvent {
  final int id;

  const LoadFeatureNameById({required this.id});

  @override
  List<Object?> get props => [id];
}

class CreateFeatureNameEvent extends FeatureNameEvent {
  final FeatureName featureName;

  const CreateFeatureNameEvent({required this.featureName});

  @override
  List<Object?> get props => [featureName];
}

class UpdateFeatureNameEvent extends FeatureNameEvent {
  final FeatureName featureName;

  const UpdateFeatureNameEvent({required this.featureName});

  @override
  List<Object?> get props => [featureName];
}

class DeleteFeatureNameEvent extends FeatureNameEvent {
  final int id;

  const DeleteFeatureNameEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

class RefreshFeatureNames extends FeatureNameEvent {}

// States
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
  final int id;

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

// BLoC
class FeatureNameBloc extends Bloc<FeatureNameEvent, FeatureNameState> {
  final GetFeatureNamesUseCase getFeatureNames;
  final GetFeatureNameByIdUseCase getFeatureNameById;
  final CreateFeatureNameUseCase createFeatureName;
  final UpdateFeatureNameUseCase updateFeatureName;
  final DeleteFeatureNameUseCase deleteFeatureName;

  FeatureNameBloc({
    required this.getFeatureNames,
    required this.getFeatureNameById,
    required this.createFeatureName,
    required this.updateFeatureName,
    required this.deleteFeatureName,
  }) : super(FeatureNameInitial()) {
    on<LoadFeatureNames>(_onLoadFeatureNames);
    on<LoadFeatureNameById>(_onLoadFeatureNameById);
    on<CreateFeatureNameEvent>(_onCreateFeatureName);
    on<UpdateFeatureNameEvent>(_onUpdateFeatureName);
    on<DeleteFeatureNameEvent>(_onDeleteFeatureName);
    on<RefreshFeatureNames>(_onRefreshFeatureNames);
  }

  Future<void> _onLoadFeatureNames(
    LoadFeatureNames event,
    Emitter<FeatureNameState> emit,
  ) async {
    if (state is! FeatureNameLoading) {
      emit(FeatureNameLoading());
      
      final result = await getFeatureNames(GetFeatureNamesParams(page: event.page));
      
      result.fold(
        (failure) => emit(FeatureNameError(message: failure.message)),
        (featureNames) => emit(FeatureNamesLoaded(
          featureNames: featureNames,
          hasReachedMax: featureNames.isEmpty,
          currentPage: event.page,
        )),
      );
    }
  }

  Future<void> _onLoadFeatureNameById(
    LoadFeatureNameById event,
    Emitter<FeatureNameState> emit,
  ) async {
    emit(FeatureNameLoading());
    
    final result = await getFeatureNameById(GetFeatureNameByIdParams(id: event.id));
    
    result.fold(
      (failure) => emit(FeatureNameError(message: failure.message)),
      (featureName) => emit(FeatureNameLoaded(featureName: featureName)),
    );
  }

  Future<void> _onCreateFeatureName(
    CreateFeatureNameEvent event,
    Emitter<FeatureNameState> emit,
  ) async {
    emit(FeatureNameLoading());
    
    final result = await createFeatureName(CreateFeatureNameParams(featureName: event.featureName));
    
    result.fold(
      (failure) => emit(FeatureNameError(message: failure.message)),
      (featureName) => emit(FeatureNameCreated(featureName: featureName)),
    );
  }

  Future<void> _onUpdateFeatureName(
    UpdateFeatureNameEvent event,
    Emitter<FeatureNameState> emit,
  ) async {
    emit(FeatureNameLoading());
    
    final result = await updateFeatureName(UpdateFeatureNameParams(featureName: event.featureName));
    
    result.fold(
      (failure) => emit(FeatureNameError(message: failure.message)),
      (featureName) => emit(FeatureNameUpdated(featureName: featureName)),
    );
  }

  Future<void> _onDeleteFeatureName(
    DeleteFeatureNameEvent event,
    Emitter<FeatureNameState> emit,
  ) async {
    emit(FeatureNameLoading());
    
    final result = await deleteFeatureName(DeleteFeatureNameParams(id: event.id));
    
    result.fold(
      (failure) => emit(FeatureNameError(message: failure.message)),
      (success) => emit(FeatureNameDeleted(id: event.id)),
    );
  }

  Future<void> _onRefreshFeatureNames(
    RefreshFeatureNames event,
    Emitter<FeatureNameState> emit,
  ) async {
    emit(FeatureNameLoading());
    
    final result = await getFeatureNames(const GetFeatureNamesParams(page: 1));
    
    result.fold(
      (failure) => emit(FeatureNameError(message: failure.message)),
      (featureNames) => emit(FeatureNamesLoaded(
        featureNames: featureNames,
        hasReachedMax: featureNames.isEmpty,
        currentPage: 1,
      )),
    );
  }
}
