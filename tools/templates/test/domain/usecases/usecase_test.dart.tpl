import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:example/core/usecases/usecase.dart';
import 'package:example/features/feature_name/domain/entities/feature_name.dart';
import 'package:example/features/feature_name/domain/repositories/feature_name_repository.dart';
import 'package:example/features/feature_name/domain/usecases/get_feature_name_usecase.dart';

import 'get_feature_name_usecase_test.mocks.dart';

@GenerateMocks([FeatureNameRepository])
void main() {
  late GetFeatureNames usecase;
  late MockFeatureNameRepository mockFeatureNameRepository;

  setUp(() {
    mockFeatureNameRepository = MockFeatureNameRepository();
    usecase = GetFeatureNames(mockFeatureNameRepository);
  });

  const tFeatureName = FeatureName(id: 'test_id');
  const tPage = 1;

  test(
    'should get FeatureNames from the repository',
    () async {
      // arrange
      when(mockFeatureNameRepository.getFeatureNames(page: tPage))
          .thenAnswer((_) async => const Right([tFeatureName]));

      // act
      final result = await usecase(const PaginationParams(page: tPage));

      // assert
      expect(result, const Right([tFeatureName]));
      verify(mockFeatureNameRepository.getFeatureNames(page: tPage));
      verifyNoMoreInteractions(mockFeatureNameRepository);
    },
  );
}

// GetFeatureNameById Test
void main() {
  late GetFeatureNameById usecase;
  late MockFeatureNameRepository mockFeatureNameRepository;

  setUp(() {
    mockFeatureNameRepository = MockFeatureNameRepository();
    usecase = GetFeatureNameById(mockFeatureNameRepository);
  });

  const tFeatureName = FeatureName(id: 'test_id');
  const tId = 'test_id';

  test(
    'should get FeatureName by ID from the repository',
    () async {
      // arrange
      when(mockFeatureNameRepository.getFeatureNameById(tId))
          .thenAnswer((_) async => const Right(tFeatureName));

      // act
      final result = await usecase(tId);

      // assert
      expect(result, const Right(tFeatureName));
      verify(mockFeatureNameRepository.getFeatureNameById(tId));
      verifyNoMoreInteractions(mockFeatureNameRepository);
    },
  );
}
