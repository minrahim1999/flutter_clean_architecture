import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:example/core/error/failures.dart';
import 'package:example/core/usecases/usecase.dart';
import 'package:example/features/FeatureName/domain/entities/FeatureName.dart';
import 'package:example/features/FeatureName/domain/usecases/get_FeatureName_usecase.dart';
import 'package:example/features/FeatureName/presentation/bloc/FeatureName_bloc.dart';
import 'package:example/features/FeatureName/presentation/bloc/FeatureName_event.dart';
import 'package:example/features/FeatureName/presentation/bloc/FeatureName_state.dart';

import 'FeatureName_bloc_test.mocks.dart';

@GenerateMocks([GetFeatureName])
void main() {
  late FeatureNameBloc bloc;
  late MockGetFeatureName mockGetFeatureName;

  setUp(() {
    mockGetFeatureName = MockGetFeatureName();
    bloc = FeatureNameBloc(getFeatureName: mockGetFeatureName);
  });

  test('initialState should be Empty', () {
    // assert
    expect(bloc.state, equals(FeatureNameInitial()));
  });

  group('GetFeatureName', () {
    const tFeatureName = FeatureName(id: 'test_id');

    test(
      'should emit [Loading, Loaded] when data is gotten successfully',
      () async {
        // arrange
        when(mockGetFeatureName(any))
            .thenAnswer((_) async => const Right(tFeatureName));

        // assert later
        final expected = [
          FeatureNameLoading(),
          const FeatureNameLoaded(tFeatureName),
        ];
        expectLater(bloc.stream, emitsInOrder(expected));

        // act
        bloc.add(GetFeatureNameEvent());
      },
    );

    test(
      'should emit [Loading, Error] when getting data fails',
      () async {
        // arrange
        when(mockGetFeatureName(any))
            .thenAnswer((_) async => Left(ServerFailure()));

        // assert later
        final expected = [
          FeatureNameLoading(),
          const FeatureNameError('Server Failure'),
        ];
        expectLater(bloc.stream, emitsInOrder(expected));

        // act
        bloc.add(GetFeatureNameEvent());
      },
    );
  });
}
