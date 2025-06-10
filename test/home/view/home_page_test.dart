import 'package:bloc_test/bloc_test.dart';
import 'package:fleet_watch/home/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/helpers.dart';

class MockHomeBloc extends MockBloc<HomeEvent, HomeState> implements HomeBloc {}

class FakeHomeEvent extends Fake implements HomeEvent {}

void main() {
  late MockHomeBloc homeBloc;

  setUpAll(() {
    registerFallbackValue(FakeHomeEvent());
  });

  setUp(() {
    homeBloc = MockHomeBloc();
  });

  group('HomePage', () {
    testWidgets('renders HomeView when state is not loading', (tester) async {
      when(() => homeBloc.state).thenReturn(MapViewInitial());
      await tester.pumpApp(const HomePage(), homeBloc: homeBloc);
      expect(find.byType(HomeView), findsOneWidget);
      expect(find.byType(CustomSearchBar), findsOneWidget);
      expect(find.byType(FilterButton), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('renders loading indicator when state is loading', (
      tester,
    ) async {
      when(() => homeBloc.state).thenReturn(MapViewLoading());
      await tester.pumpApp(const HomePage(), homeBloc: homeBloc);
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(HomeView), findsNothing);
      expect(find.byType(CustomSearchBar), findsNothing);
      expect(find.byType(FilterButton), findsNothing);
      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('tapping FloatingActionButton calls MapUpdateCars event', (
      tester,
    ) async {
      when(() => homeBloc.state).thenReturn(MapViewInitial());
      await tester.pumpApp(const HomePage(), homeBloc: homeBloc);
      await tester.tap(find.byType(FloatingActionButton));
      verify(() => homeBloc.add(MapUpdateCars())).called(1);
    });
  });
}
