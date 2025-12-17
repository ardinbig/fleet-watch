import 'package:bloc_test/bloc_test.dart';
import 'package:fleet_watch/home/home.dart';
import 'package:fleet_watch/l10n/arb/app_localizations.dart';
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

  group('CustomSearchBar', () {
    testWidgets('renders correctly', (tester) async {
      await tester.pumpApp(
        const Scaffold(body: CustomSearchBar()),
        homeBloc: homeBloc,
      );
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('displays correct hint text', (tester) async {
      await tester.pumpApp(
        const Scaffold(body: CustomSearchBar()),
        homeBloc: homeBloc,
      );
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(CustomSearchBar));
      final l10n = AppLocalizations.of(context);
      expect(find.text(l10n.searchHintText), findsOneWidget);
    });

    testWidgets('adds MapSearchQueryChanged event when text is changed', (
      tester,
    ) async {
      await tester.pumpApp(
        const Scaffold(body: CustomSearchBar()),
        homeBloc: homeBloc,
      );
      await tester.enterText(find.byType(TextField), 'test query');
      verify(
        () => homeBloc.add(const MapSearchQueryChanged('test query')),
      ).called(1);
    });
  });
}
