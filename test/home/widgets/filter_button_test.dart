import 'package:bloc_test/bloc_test.dart';
import 'package:fleet_watch/home/home.dart';
import 'package:fleet_watch/l10n/arb/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/helpers.dart';

class MockHomeBloc extends MockBloc<HomeEvent, HomeState> implements HomeBloc {}

class FakeHomeEvent extends Fake implements HomeEvent {}

class MockMapViewLoaded extends Mock implements MapViewLoaded {}

void main() {
  late MockHomeBloc homeBloc;
  late MapViewLoaded mapViewLoaded;

  setUpAll(() {
    registerFallbackValue(FakeHomeEvent());
  });

  setUp(() {
    homeBloc = MockHomeBloc();
    mapViewLoaded = MockMapViewLoaded();
    when(() => mapViewLoaded.filterStatus).thenReturn('All');
  });

  group('FilterButton', () {
    testWidgets('renders correctly when state is not MapViewLoaded', (
      tester,
    ) async {
      when(() => homeBloc.state).thenReturn(MapViewInitial());
      await tester.pumpApp(
        const Scaffold(body: FilterButton()),
        homeBloc: homeBloc,
      );
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(FilterButton));
      final l10n = AppLocalizations.of(context);
      expect(find.text(l10n.filterAll), findsOneWidget);
      expect(find.byIcon(Icons.filter_list), findsOneWidget);
    });

    testWidgets('renders with correct filter when state is MapViewLoaded', (
      tester,
    ) async {
      when(() => mapViewLoaded.filterStatus).thenReturn('Moving');
      when(() => homeBloc.state).thenReturn(mapViewLoaded);
      await tester.pumpApp(
        const Scaffold(body: FilterButton()),
        homeBloc: homeBloc,
      );
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(FilterButton));
      final l10n = AppLocalizations.of(context);
      expect(find.text(l10n.filterMoving), findsOneWidget);
    });

    testWidgets('opens popup menu when tapped', (tester) async {
      when(() => homeBloc.state).thenReturn(MapViewInitial());
      await tester.pumpApp(
        const Scaffold(body: FilterButton()),
        homeBloc: homeBloc,
      );
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(FilterButton));
      final l10n = AppLocalizations.of(context);
      expect(find.text(l10n.filterAll), findsWidgets);
      expect(find.text(l10n.filterMoving), findsOneWidget);
      expect(find.text(l10n.filterParked), findsOneWidget);
    });

    testWidgets('adds MapFilterStatusChanged event when filter is selected', (
      tester,
    ) async {
      when(() => homeBloc.state).thenReturn(MapViewInitial());
      await tester.pumpApp(
        const Scaffold(body: FilterButton()),
        homeBloc: homeBloc,
      );
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(FilterButton));
      final l10n = AppLocalizations.of(context);
      await tester.tap(find.text(l10n.filterMoving).last);
      await tester.pumpAndSettle();
      verify(
        () => homeBloc.add(const MapFilterStatusChanged('Moving')),
      ).called(1);
    });

    group('_getFilterText', () {
      testWidgets('returns correct text for All filter', (tester) async {
        when(() => mapViewLoaded.filterStatus).thenReturn('All');
        when(() => homeBloc.state).thenReturn(mapViewLoaded);
        await tester.pumpApp(
          const Scaffold(body: FilterButton()),
          homeBloc: homeBloc,
        );
        await tester.pumpAndSettle();
        final context = tester.element(find.byType(FilterButton));
        final l10n = AppLocalizations.of(context);
        expect(find.text(l10n.filterAll), findsOneWidget);
      });

      testWidgets('returns correct text for Moving filter', (tester) async {
        when(() => mapViewLoaded.filterStatus).thenReturn('Moving');
        when(() => homeBloc.state).thenReturn(mapViewLoaded);
        await tester.pumpApp(
          const Scaffold(body: FilterButton()),
          homeBloc: homeBloc,
        );
        await tester.pumpAndSettle();
        final context = tester.element(find.byType(FilterButton));
        final l10n = AppLocalizations.of(context);
        expect(find.text(l10n.filterMoving), findsOneWidget);
      });

      testWidgets('returns correct text for Parked filter', (tester) async {
        when(() => mapViewLoaded.filterStatus).thenReturn('Parked');
        when(() => homeBloc.state).thenReturn(mapViewLoaded);
        await tester.pumpApp(
          const Scaffold(body: FilterButton()),
          homeBloc: homeBloc,
        );
        await tester.pumpAndSettle();
        final context = tester.element(find.byType(FilterButton));
        final l10n = AppLocalizations.of(context);
        expect(find.text(l10n.filterParked), findsOneWidget);
      });

      testWidgets('returns default text for unknown filter', (tester) async {
        when(() => mapViewLoaded.filterStatus).thenReturn('Unknown');
        when(() => homeBloc.state).thenReturn(mapViewLoaded);
        await tester.pumpApp(
          const Scaffold(body: FilterButton()),
          homeBloc: homeBloc,
        );
        await tester.pumpAndSettle();
        final context = tester.element(find.byType(FilterButton));
        final l10n = AppLocalizations.of(context);
        expect(find.text(l10n.filterAll), findsOneWidget);
      });
    });
  });
}
