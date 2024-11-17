import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:my_app/core/error/failures.dart';
import 'package:my_app/core/usecases/usecase.dart';
import 'package:my_app/features/feature_name/domain/entities/feature_name.dart';
import 'package:my_app/features/feature_name/domain/usecases/get_feature_names_usecase.dart';
import 'package:my_app/features/feature_name/domain/usecases/create_feature_name_usecase.dart';
import 'package:my_app/features/feature_name/domain/usecases/update_feature_name_usecase.dart';
import 'package:my_app/features/feature_name/domain/usecases/delete_feature_name_usecase.dart';
import 'package:my_app/features/feature_name/presentation/bloc/feature_name_bloc.dart';

import 'feature_name_bloc_test.mocks.dart';

@GenerateMocks([
  GetFeatureNamesUseCase,
  CreateFeatureNameUseCase,
  UpdateFeatureNameUseCase,
  DeleteFeatureNameUseCase,
])
void main() {
  late FeatureNameBloc bloc;
  late MockGetFeatureNamesUseCase mockGetFeatureNamesUseCase;
  late MockCreateFeatureNameUseCase mockCreateFeatureNameUseCase;
  late MockUpdateFeatureNameUseCase mockUpdateFeatureNameUseCase;
  late MockDeleteFeatureNameUseCase mockDeleteFeatureNameUseCase;

  setUp(() {
    mockGetFeatureNamesUseCase = MockGetFeatureNamesUseCase();
    mockCreateFeatureNameUseCase = MockCreateFeatureNameUseCase();
    mockUpdateFeatureNameUseCase = MockUpdateFeatureNameUseCase();
    mockDeleteFeatureNameUseCase = MockDeleteFeatureNameUseCase();

    bloc = FeatureNameBloc(
      getFeatureNames: mockGetFeatureNamesUseCase,
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
    title: 'Test FeatureName',
    description: 'Test Description',
  );
  final List<FeatureName> tFeatureNames = [tFeatureName];

  group('GetFeatureNames', () {
    blocTest<FeatureNameBloc, FeatureNameState>(
      'should emit [Loading, Loaded] when data is gotten successfully',
      build: () {
        when(mockGetFeatureNamesUseCase(NoParams()))
            .thenAnswer((_) async => Right(tFeatureNames));
        return bloc;
      },
      act: (bloc) => bloc.add(GetFeatureNamesEvent()),
      expect: () => [
        FeatureNameLoading(),
        FeatureNameLoaded(featureNames: tFeatureNames),
      ],
      verify: (_) {
        verify(mockGetFeatureNamesUseCase(NoParams()));
      },
    );

    blocTest<FeatureNameBloc, FeatureNameState>(
      'should emit [Loading, Error] when getting data fails',
      build: () {
        when(mockGetFeatureNamesUseCase(NoParams()))
            .thenAnswer((_) async => Left(ServerFailure('Server error')));
        return bloc;
      },
      act: (bloc) => bloc.add(GetFeatureNamesEvent()),
      expect: () => [
        FeatureNameLoading(),
        const FeatureNameError(message: 'Server error'),
      ],
      verify: (_) {
        verify(mockGetFeatureNamesUseCase(NoParams()));
      },
    );
  });

  group('CreateFeatureName', () {
    final tCreateFeatureNameParams = CreateFeatureNameParams(
      title: 'Test FeatureName',
      description: 'Test Description',
    );

    blocTest<FeatureNameBloc, FeatureNameState>(
      'should emit [Loading, Success] when creating data succeeds',
      build: () {
        when(mockCreateFeatureNameUseCase(tCreateFeatureNameParams))
            .thenAnswer((_) async => Right(tFeatureName));
        return bloc;
      },
      act: (bloc) => bloc.add(CreateFeatureNameEvent(
        title: tCreateFeatureNameParams.title,
        description: tCreateFeatureNameParams.description,
      )),
      expect: () => [
        FeatureNameLoading(),
        FeatureNameSuccess(message: 'FeatureName created successfully'),
      ],
      verify: (_) {
        verify(mockCreateFeatureNameUseCase(tCreateFeatureNameParams));
      },
    );
  });
}
