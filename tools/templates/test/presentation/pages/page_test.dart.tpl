import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:example/features/FeatureName/domain/entities/FeatureName.dart';
import 'package:example/features/FeatureName/presentation/bloc/FeatureName_bloc.dart';
import 'package:example/features/FeatureName/presentation/bloc/FeatureName_event.dart';
import 'package:example/features/FeatureName/presentation/bloc/FeatureName_state.dart';
import 'package:example/features/FeatureName/presentation/pages/FeatureName_page.dart';

import 'FeatureName_page_test.mocks.dart';

@GenerateMocks([FeatureNameBloc])
void main() {
  late MockFeatureNameBloc mockFeatureNameBloc;

  setUp(() {
    mockFeatureNameBloc = MockFeatureNameBloc();
  });

  Widget makeTestableWidget() {
    return MaterialApp(
      home: BlocProvider<FeatureNameBloc>(
        create: (context) => mockFeatureNameBloc,
        child: const FeatureNamePage(),
      ),
    );
  }

  testWidgets(
    'should show loading widget when state is loading',
    (WidgetTester tester) async {
      // arrange
      when(mockFeatureNameBloc.state).thenReturn(FeatureNameLoading());

      // act
      await tester.pumpWidget(makeTestableWidget());

      // assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    },
  );

  testWidgets(
    'should show content when state is loaded',
    (WidgetTester tester) async {
      // arrange
      const tFeatureName = FeatureName(id: 'test_id');
      when(mockFeatureNameBloc.state)
          .thenReturn(const FeatureNameLoaded(tFeatureName));

      // act
      await tester.pumpWidget(makeTestableWidget());

      // assert
      expect(find.text('FeatureName Content: test_id'), findsOneWidget);
    },
  );

  testWidgets(
    'should show error message when state is error',
    (WidgetTester tester) async {
      // arrange
      when(mockFeatureNameBloc.state)
          .thenReturn(const FeatureNameError('Error message'));

      // act
      await tester.pumpWidget(makeTestableWidget());

      // assert
      expect(find.text('Error: Error message'), findsOneWidget);
    },
  );
}
