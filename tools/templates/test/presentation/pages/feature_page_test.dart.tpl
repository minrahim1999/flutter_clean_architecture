import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:example/core/widgets/error_widget.dart';
import 'package:example/core/widgets/loading_widget.dart';
import 'package:example/features/feature_name/domain/entities/feature_name.dart';
import 'package:example/features/feature_name/presentation/bloc/feature_name_bloc.dart';
import 'package:example/features/feature_name/presentation/bloc/feature_name_event.dart';
import 'package:example/features/feature_name/presentation/bloc/feature_name_state.dart';
import 'package:example/features/feature_name/presentation/pages/feature_name_page.dart';
import 'package:example/features/feature_name/presentation/widgets/feature_name_form.dart';
import 'package:example/features/feature_name/presentation/widgets/feature_name_list_item.dart';

class MockFeatureNameBloc extends Mock implements FeatureNameBloc {}

void main() {
  late MockFeatureNameBloc mockBloc;

  setUp(() {
    mockBloc = MockFeatureNameBloc();
  });

  Widget makeTestableWidget(Widget child) {
    return MaterialApp(
      home: BlocProvider<FeatureNameBloc>(
        create: (context) => mockBloc,
        child: child,
      ),
    );
  }

  final tFeatureName = FeatureName(
    id: '1',
    name: 'Test Feature',
    description: 'Test Description',
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 2),
  );

  group('Initial State', () {
    testWidgets(
      'should show loading indicator when state is initial',
      (WidgetTester tester) async {
        // Arrange
        when(mockBloc.state).thenReturn(FeatureNameInitial());

        // Act
        await tester.pumpWidget(makeTestableWidget(const FeatureNamePage()));
        await tester.pump();

        // Assert
        expect(find.byType(LoadingWidget), findsOneWidget);
        expect(find.byType(ErrorWidget), findsNothing);
        expect(find.byType(FeatureNameListItem), findsNothing);
      },
    );
  });

  group('Loading State', () {
    testWidgets(
      'should show loading indicator when state is loading',
      (WidgetTester tester) async {
        // Arrange
        when(mockBloc.state).thenReturn(FeatureNameLoading());

        // Act
        await tester.pumpWidget(makeTestableWidget(const FeatureNamePage()));
        await tester.pump();

        // Assert
        expect(find.byType(LoadingWidget), findsOneWidget);
        expect(find.byType(ErrorWidget), findsNothing);
        expect(find.byType(FeatureNameListItem), findsNothing);
      },
    );

    testWidgets(
      'should disable interaction while loading',
      (WidgetTester tester) async {
        // Arrange
        when(mockBloc.state).thenReturn(FeatureNameLoading());

        // Act
        await tester.pumpWidget(makeTestableWidget(const FeatureNamePage()));
        await tester.pump();

        // Assert
        expect(find.byType(AbsorbPointer), findsOneWidget);
      },
    );
  });

  group('Loaded State', () {
    testWidgets(
      'should show feature content when state is loaded',
      (WidgetTester tester) async {
        // Arrange
        when(mockBloc.state).thenReturn(FeatureNameLoaded(featureName: tFeatureName));

        // Act
        await tester.pumpWidget(makeTestableWidget(const FeatureNamePage()));
        await tester.pump();

        // Assert
        expect(find.byType(LoadingWidget), findsNothing);
        expect(find.byType(ErrorWidget), findsNothing);
        expect(find.byType(FeatureNameListItem), findsOneWidget);
        expect(find.text(tFeatureName.name), findsOneWidget);
        expect(find.text(tFeatureName.description!), findsOneWidget);
      },
    );

    testWidgets(
      'should show empty message when loaded with no data',
      (WidgetTester tester) async {
        // Arrange
        when(mockBloc.state).thenReturn(const FeatureNameLoaded(featureName: null));

        // Act
        await tester.pumpWidget(makeTestableWidget(const FeatureNamePage()));
        await tester.pump();

        // Assert
        expect(find.text('No feature found'), findsOneWidget);
      },
    );
  });

  group('Error State', () {
    testWidgets(
      'should show error message when state is error',
      (WidgetTester tester) async {
        // Arrange
        const errorMessage = 'Something went wrong';
        when(mockBloc.state).thenReturn(FeatureNameError(message: errorMessage));

        // Act
        await tester.pumpWidget(makeTestableWidget(const FeatureNamePage()));
        await tester.pump();

        // Assert
        expect(find.byType(ErrorWidget), findsOneWidget);
        expect(find.text(errorMessage), findsOneWidget);
        expect(find.byType(LoadingWidget), findsNothing);
        expect(find.byType(FeatureNameListItem), findsNothing);
      },
    );

    testWidgets(
      'should show retry button when in error state',
      (WidgetTester tester) async {
        // Arrange
        when(mockBloc.state).thenReturn(FeatureNameError(message: 'Error'));

        // Act
        await tester.pumpWidget(makeTestableWidget(const FeatureNamePage()));
        await tester.pump();

        // Assert
        expect(find.byType(ElevatedButton), findsOneWidget);
        expect(find.text('Retry'), findsOneWidget);
      },
    );
  });

  group('User Interactions', () {
    testWidgets(
      'should trigger GetFeatureNameEvent when refresh button is pressed',
      (WidgetTester tester) async {
        // Arrange
        when(mockBloc.state).thenReturn(FeatureNameInitial());

        // Act
        await tester.pumpWidget(makeTestableWidget(const FeatureNamePage()));
        await tester.tap(find.byType(IconButton));
        await tester.pump();

        // Assert
        verify(mockBloc.add(GetFeatureNameEvent())).called(1);
      },
    );

    testWidgets(
      'should trigger CreateFeatureNameEvent when form is submitted',
      (WidgetTester tester) async {
        // Arrange
        when(mockBloc.state).thenReturn(FeatureNameInitial());

        // Act
        await tester.pumpWidget(makeTestableWidget(const FeatureNamePage()));
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        // Fill form
        await tester.enterText(find.byType(TextFormField).first, 'New Feature');
        await tester.enterText(find.byType(TextFormField).last, 'New Description');
        await tester.tap(find.text('Submit'));
        await tester.pump();

        // Assert
        verify(mockBloc.add(any)).called(1);
      },
    );

    testWidgets(
      'should trigger UpdateFeatureNameEvent when edit button is pressed',
      (WidgetTester tester) async {
        // Arrange
        when(mockBloc.state).thenReturn(FeatureNameLoaded(featureName: tFeatureName));

        // Act
        await tester.pumpWidget(makeTestableWidget(const FeatureNamePage()));
        await tester.tap(find.byIcon(Icons.edit));
        await tester.pumpAndSettle();

        // Fill form
        await tester.enterText(find.byType(TextFormField).first, 'Updated Feature');
        await tester.tap(find.text('Update'));
        await tester.pump();

        // Assert
        verify(mockBloc.add(any)).called(1);
      },
    );

    testWidgets(
      'should trigger DeleteFeatureNameEvent when delete button is pressed',
      (WidgetTester tester) async {
        // Arrange
        when(mockBloc.state).thenReturn(FeatureNameLoaded(featureName: tFeatureName));

        // Act
        await tester.pumpWidget(makeTestableWidget(const FeatureNamePage()));
        await tester.tap(find.byIcon(Icons.delete));
        await tester.pumpAndSettle();

        // Confirm deletion
        await tester.tap(find.text('Yes'));
        await tester.pump();

        // Assert
        verify(mockBloc.add(DeleteFeatureNameEvent(id: tFeatureName.id))).called(1);
      },
    );

    testWidgets(
      'should show confirmation dialog when delete button is pressed',
      (WidgetTester tester) async {
        // Arrange
        when(mockBloc.state).thenReturn(FeatureNameLoaded(featureName: tFeatureName));

        // Act
        await tester.pumpWidget(makeTestableWidget(const FeatureNamePage()));
        await tester.tap(find.byIcon(Icons.delete));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Delete Feature'), findsOneWidget);
        expect(find.text('Are you sure you want to delete this feature?'), findsOneWidget);
        expect(find.text('Yes'), findsOneWidget);
        expect(find.text('No'), findsOneWidget);
      },
    );
  });
}
