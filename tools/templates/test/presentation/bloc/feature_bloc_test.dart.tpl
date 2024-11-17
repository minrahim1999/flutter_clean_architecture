import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:example/core/error/failures.dart';
import 'package:example/core/usecases/usecase.dart';
import 'package:example/features/feature_name/domain/entities/feature_name.dart';
import 'package:example/features/feature_name/domain/usecases/get_feature_name_usecase.dart';
import 'package:example/features/feature_name/domain/usecases/create_feature_name_usecase.dart';
import 'package:example/features/feature_name/domain/usecases/update_feature_name_usecase.dart';
import 'package:example/features/feature_name/domain/usecases/delete_feature_name_usecase.dart';
import 'package:example/features/feature_name/presentation/bloc/feature_name_bloc.dart';
import 'package:example/features/feature_name/presentation/bloc/feature_name_event.dart';
import 'package:example/features/feature_name/presentation/bloc/feature_name_state.dart';

class MockGetFeatureNameUseCase extends Mock implements GetFeatureNameUseCase {}
class MockCreateFeatureNameUseCase extends Mock implements CreateFeatureNameUseCase {}
class MockUpdateFeatureNameUseCase extends Mock implements UpdateFeatureNameUseCase {}
class MockDeleteFeatureNameUseCase extends Mock implements DeleteFeatureNameUseCase {}

void main() {
  late FeatureNameBloc bloc;
  late MockGetFeatureNameUseCase mockGetFeatureNameUseCase;
  late MockCreateFeatureNameUseCase mockCreateFeatureNameUseCase;
  late MockUpdateFeatureNameUseCase mockUpdateFeatureNameUseCase;
  late MockDeleteFeatureNameUseCase mockDeleteFeatureNameUseCase;

  setUp(() {
    mockGetFeatureNameUseCase = MockGetFeatureNameUseCase();
    mockCreateFeatureNameUseCase = MockCreateFeatureNameUseCase();
    mockUpdateFeatureNameUseCase = MockUpdateFeatureNameUseCase();
    mockDeleteFeatureNameUseCase = MockDeleteFeatureNameUseCase();
    bloc = FeatureNameBloc(
      getFeatureName: mockGetFeatureNameUseCase,
      createFeatureName: mockCreateFeatureNameUseCase,
      updateFeatureName: mockUpdateFeatureNameUseCase,
      deleteFeatureName: mockDeleteFeatureNameUseCase,
    );
  });

  tearDown(() {
    bloc.close();
  });

  test('initial state should be FeatureNameInitial', () {
    expect(bloc.state, equals(FeatureNameInitial()));
  });

  final tFeatureName = FeatureName(
    id: '1',
    name: 'Test Feature',
    description: 'Test Description',
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 2),
  );

  group('GetFeatureNameEvent', () {
    blocTest<FeatureNameBloc, FeatureNameState>(
      'should emit [Loading, Loaded] when data is gotten successfully',
      build: () {
        when(mockGetFeatureNameUseCase(any))
            .thenAnswer((_) async => Right(tFeatureName));
        return bloc;
      },
      act: (bloc) => bloc.add(GetFeatureNameEvent()),
      expect: () => [
        FeatureNameLoading(),
        FeatureNameLoaded(featureName: tFeatureName),
      ],
      verify: (bloc) {
        verify(mockGetFeatureNameUseCase(NoParams()));
      },
    );

    blocTest<FeatureNameBloc, FeatureNameState>(
      'should emit [Loading, Error] when getting data fails with ServerFailure',
      build: () {
        when(mockGetFeatureNameUseCase(any))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(GetFeatureNameEvent()),
      expect: () => [
        FeatureNameLoading(),
        FeatureNameError(message: SERVER_FAILURE_MESSAGE),
      ],
      verify: (bloc) {
        verify(mockGetFeatureNameUseCase(NoParams()));
      },
    );

    blocTest<FeatureNameBloc, FeatureNameState>(
      'should emit [Loading, Error] when getting data fails with CacheFailure',
      build: () {
        when(mockGetFeatureNameUseCase(any))
            .thenAnswer((_) async => Left(CacheFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(GetFeatureNameEvent()),
      expect: () => [
        FeatureNameLoading(),
        FeatureNameError(message: CACHE_FAILURE_MESSAGE),
      ],
      verify: (bloc) {
        verify(mockGetFeatureNameUseCase(NoParams()));
      },
    );
  });

  group('CreateFeatureNameEvent', () {
    blocTest<FeatureNameBloc, FeatureNameState>(
      'should emit [Loading, Created] when creation is successful',
      build: () {
        when(mockCreateFeatureNameUseCase(any))
            .thenAnswer((_) async => Right(tFeatureName));
        return bloc;
      },
      act: (bloc) => bloc.add(CreateFeatureNameEvent(featureName: tFeatureName)),
      expect: () => [
        FeatureNameLoading(),
        FeatureNameCreated(featureName: tFeatureName),
      ],
      verify: (bloc) {
        verify(mockCreateFeatureNameUseCase(CreateFeatureNameParams(featureName: tFeatureName)));
      },
    );

    blocTest<FeatureNameBloc, FeatureNameState>(
      'should emit [Loading, Error] when creation fails with ServerFailure',
      build: () {
        when(mockCreateFeatureNameUseCase(any))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(CreateFeatureNameEvent(featureName: tFeatureName)),
      expect: () => [
        FeatureNameLoading(),
        FeatureNameError(message: SERVER_FAILURE_MESSAGE),
      ],
      verify: (bloc) {
        verify(mockCreateFeatureNameUseCase(CreateFeatureNameParams(featureName: tFeatureName)));
      },
    );

    blocTest<FeatureNameBloc, FeatureNameState>(
      'should emit [Loading, Error] when creation fails with ValidationFailure',
      build: () {
        when(mockCreateFeatureNameUseCase(any))
            .thenAnswer((_) async => Left(ValidationFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(CreateFeatureNameEvent(featureName: tFeatureName)),
      expect: () => [
        FeatureNameLoading(),
        FeatureNameError(message: VALIDATION_FAILURE_MESSAGE),
      ],
      verify: (bloc) {
        verify(mockCreateFeatureNameUseCase(CreateFeatureNameParams(featureName: tFeatureName)));
      },
    );
  });

  group('UpdateFeatureNameEvent', () {
    blocTest<FeatureNameBloc, FeatureNameState>(
      'should emit [Loading, Updated] when update is successful',
      build: () {
        when(mockUpdateFeatureNameUseCase(any))
            .thenAnswer((_) async => Right(tFeatureName));
        return bloc;
      },
      act: (bloc) => bloc.add(UpdateFeatureNameEvent(featureName: tFeatureName)),
      expect: () => [
        FeatureNameLoading(),
        FeatureNameUpdated(featureName: tFeatureName),
      ],
      verify: (bloc) {
        verify(mockUpdateFeatureNameUseCase(UpdateFeatureNameParams(featureName: tFeatureName)));
      },
    );

    blocTest<FeatureNameBloc, FeatureNameState>(
      'should emit [Loading, Error] when update fails with ServerFailure',
      build: () {
        when(mockUpdateFeatureNameUseCase(any))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(UpdateFeatureNameEvent(featureName: tFeatureName)),
      expect: () => [
        FeatureNameLoading(),
        FeatureNameError(message: SERVER_FAILURE_MESSAGE),
      ],
      verify: (bloc) {
        verify(mockUpdateFeatureNameUseCase(UpdateFeatureNameParams(featureName: tFeatureName)));
      },
    );

    blocTest<FeatureNameBloc, FeatureNameState>(
      'should emit [Loading, Error] when update fails with NotFoundFailure',
      build: () {
        when(mockUpdateFeatureNameUseCase(any))
            .thenAnswer((_) async => Left(NotFoundFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(UpdateFeatureNameEvent(featureName: tFeatureName)),
      expect: () => [
        FeatureNameLoading(),
        FeatureNameError(message: NOT_FOUND_FAILURE_MESSAGE),
      ],
      verify: (bloc) {
        verify(mockUpdateFeatureNameUseCase(UpdateFeatureNameParams(featureName: tFeatureName)));
      },
    );
  });

  group('DeleteFeatureNameEvent', () {
    blocTest<FeatureNameBloc, FeatureNameState>(
      'should emit [Loading, Deleted] when deletion is successful',
      build: () {
        when(mockDeleteFeatureNameUseCase(any))
            .thenAnswer((_) async => const Right(true));
        return bloc;
      },
      act: (bloc) => bloc.add(DeleteFeatureNameEvent(id: tFeatureName.id)),
      expect: () => [
        FeatureNameLoading(),
        const FeatureNameDeleted(),
      ],
      verify: (bloc) {
        verify(mockDeleteFeatureNameUseCase(DeleteFeatureNameParams(id: tFeatureName.id)));
      },
    );

    blocTest<FeatureNameBloc, FeatureNameState>(
      'should emit [Loading, Error] when deletion fails with ServerFailure',
      build: () {
        when(mockDeleteFeatureNameUseCase(any))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(DeleteFeatureNameEvent(id: tFeatureName.id)),
      expect: () => [
        FeatureNameLoading(),
        FeatureNameError(message: SERVER_FAILURE_MESSAGE),
      ],
      verify: (bloc) {
        verify(mockDeleteFeatureNameUseCase(DeleteFeatureNameParams(id: tFeatureName.id)));
      },
    );

    blocTest<FeatureNameBloc, FeatureNameState>(
      'should emit [Loading, Error] when deletion fails with NotFoundFailure',
      build: () {
        when(mockDeleteFeatureNameUseCase(any))
            .thenAnswer((_) async => Left(NotFoundFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(DeleteFeatureNameEvent(id: tFeatureName.id)),
      expect: () => [
        FeatureNameLoading(),
        FeatureNameError(message: NOT_FOUND_FAILURE_MESSAGE),
      ],
      verify: (bloc) {
        verify(mockDeleteFeatureNameUseCase(DeleteFeatureNameParams(id: tFeatureName.id)));
      },
    );
  });
}
