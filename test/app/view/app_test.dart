import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:fleet_repository/fleet_repository.dart';
import 'package:fleet_watch/app/app.dart';
import 'package:fleet_watch/home/home.dart';
import 'package:fleet_watch/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/pump_app.dart';

class MockHomeBloc extends MockBloc<HomeEvent, HomeState> implements HomeBloc {}

void main() {
  late FleetRepository fleetRepository;

  setUp(() {
    fleetRepository = MockFleetRepository();

    when(
      () => fleetRepository.fetchAndCacheCars(),
    ).thenAnswer((_) async => <Car>[]);
    when(
      () => fleetRepository.getCachedCars(),
    ).thenAnswer((_) async => <Car>[]);
    when(() => fleetRepository.dispose()).thenAnswer((_) async {});
  });

  group('App', () {
    testWidgets('renders AppView', (tester) async {
      await tester.pumpWidget(
        App(createFleetRepository: () => fleetRepository),
      );
      expect(find.byType(AppView), findsOneWidget);
    });

    testWidgets('creates HomeBloc and loads cars', (tester) async {
      await tester.pumpWidget(
        App(createFleetRepository: () => fleetRepository),
      );
      await tester.pumpAndSettle();
      verify(() => fleetRepository.fetchAndCacheCars()).called(1);
    });
  });

  group('AppView', () {
    testWidgets('renders HomePage', (tester) async {
      await tester.pumpApp(const AppView());
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('shows offline snackbar when state is offline', (tester) async {
      // Use a real connectivity bloc but manually control its state
      final connectivityBloc = ConnectivityBloc();
      await tester.pumpApp(const AppView(), connectivityBloc: connectivityBloc);
      // Emit the offline state to trigger snackbar
      connectivityBloc.emit(const ConnectivityState(isOnline: false));

      await tester.pump();

      expect(find.byType(AwesomeSnackbarContent), findsOneWidget);
      final snackbarContent = tester.widget<AwesomeSnackbarContent>(
        find.byType(AwesomeSnackbarContent).first,
      );

      final context = tester.element(find.byType(AppView));
      final l10n = context.l10n;

      expect(snackbarContent.title, l10n.offlineTitle);
      expect(snackbarContent.message, l10n.offlineMessage);
      expect(snackbarContent.contentType, ContentType.warning);

      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar).first);
      expect(snackBar.behavior, SnackBarBehavior.floating);
      expect(snackBar.duration, const Duration(days: 1));
    });

    testWidgets('shows error snackbar when HomeBloc emits MapViewError', (
      tester,
    ) async {
      final homeBloc = MockHomeBloc();
      const errorMessage = 'Test error message';

      whenListen(
        homeBloc,
        Stream.fromIterable([const MapViewError(errorMessage)]),
        initialState: MapViewInitial(),
      );

      await tester.pumpApp(const AppView(), homeBloc: homeBloc);
      await tester.pump();

      expect(find.byType(AwesomeSnackbarContent), findsOneWidget);
      final snackbarContent = tester.widget<AwesomeSnackbarContent>(
        find.byType(AwesomeSnackbarContent).first,
      );

      final context = tester.element(find.byType(AppView));
      final l10n = context.l10n;

      expect(snackbarContent.title, l10n.errorTitle);
      expect(snackbarContent.message, errorMessage);
      expect(snackbarContent.contentType, ContentType.failure);

      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar).first);
      expect(snackBar.behavior, SnackBarBehavior.floating);
      expect(snackBar.duration, const Duration(seconds: 3)); // Default duration
    });
  });

  group('showSnackBar', () {
    testWidgets('displays snackbar with correct content', (tester) async {
      const title = 'Test Title';
      const message = 'Test Message';
      const contentType = ContentType.help;

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox())),
      );
      final context = tester.element(find.byType(SizedBox));

      showSnackBar(
        context: context,
        title: title,
        message: message,
        contentType: contentType,
      );
      await tester.pump();

      expect(find.byType(AwesomeSnackbarContent), findsOneWidget);
      final snackbarContent = tester.widget<AwesomeSnackbarContent>(
        find.byType(AwesomeSnackbarContent),
      );
      expect(snackbarContent.title, title);
      expect(snackbarContent.message, message);
      expect(snackbarContent.contentType, contentType);

      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.behavior, SnackBarBehavior.floating);
    });

    testWidgets('uses custom duration when provided', (tester) async {
      const duration = Duration(seconds: 10);

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox())),
      );
      final context = tester.element(find.byType(SizedBox));

      showSnackBar(
        context: context,
        title: 'Title',
        message: 'Message',
        contentType: ContentType.success,
        duration: duration,
      );
      await tester.pump();

      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.duration, duration);
    });
  });
}
