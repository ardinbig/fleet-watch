import 'package:bloc_test/bloc_test.dart';
import 'package:fleet_repository/fleet_repository.dart';
import 'package:fleet_watch/app/bloc/connectivity_bloc.dart';
import 'package:fleet_watch/car_detail/car_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/pump_app.dart';

class MockFleetRepository extends Mock implements FleetRepository {}

class MockCarDetailBloc extends MockBloc<CarDetailEvent, CarDetailState>
    implements CarDetailBloc {}

class MockConnectivityBloc
    extends MockBloc<ConnectivityEvent, ConnectivityState>
    implements ConnectivityBloc {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class MockGoogleMapController extends Mock implements GoogleMapController {}

void main() {
  late MockNavigatorObserver navigatorObserver;
  late FleetRepository repository;
  late ConnectivityBloc connectivityBloc;
  late CarDetailBloc carDetailBloc;
  late Car testCar;

  setUp(() {
    repository = MockFleetRepository();
    carDetailBloc = MockCarDetailBloc();
    navigatorObserver = MockNavigatorObserver();
    connectivityBloc = MockConnectivityBloc();

    testCar = const Car(
      id: '1',
      name: 'Test Car',
      latitude: 0,
      longitude: 0,
      speed: 0,
      status: CarStatus.parked,
    );

    registerFallbackValue(StartTrackingCar(testCar));
    registerFallbackValue(MapControllerUpdated(MockGoogleMapController()));
    registerFallbackValue(const ToggleTracking());
  });

  group('CarDetailPage', () {
    setUp(() {
      when(
        () => repository.fetchAndCacheCarDetails(any()),
      ).thenAnswer((_) async => testCar);
    });

    testWidgets('provides CarDetailBloc and renders CarDetailView', (
      tester,
    ) async {
      await tester.pumpApp(
        CarDetailPage(car: testCar, repository: repository),
        carDetailBloc: carDetailBloc,
      );
      expect(find.byType(CarDetailView), findsOneWidget);
    });
  });

  group('CarDetailView', () {
    Future<void> navigateToCarDetailView(
      WidgetTester tester, {
      required bool isTracking,
    }) async {
      when(
        () => carDetailBloc.state,
      ).thenReturn(CarDetailState(car: testCar, isTracking: isTracking));

      await tester.pumpApp(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => BlocProvider.value(
                    value: carDetailBloc,
                    child: CarDetailView(car: testCar),
                  ),
                ),
              );
            },
            child: const Text('Navigate'),
          ),
        ),
        navigatorObservers: [navigatorObserver],
      );

      // Navigate
      await tester.tap(find.text('Navigate'));
      await tester.pump();
      await tester.pump();

      // Go back
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump();
      await tester.pump();
    }

    setUp(() {
      when(
        () => carDetailBloc.state,
      ).thenReturn(CarDetailState(car: testCar, isTracking: false));
    });

    testWidgets('renders AppBar with car name', (tester) async {
      await tester.pumpApp(
        CarDetailPage(car: testCar, repository: repository),
        carDetailBloc: carDetailBloc,
      );
      expect(find.text('Test Car'), findsOneWidget);
    });

    testWidgets('renders car info section, map section and tracking button', (
      tester,
    ) async {
      await tester.pumpApp(
        CarDetailPage(car: testCar, repository: repository),
        carDetailBloc: carDetailBloc,
      );
      expect(find.text('Test Car'), findsOneWidget);
      expect(find.byType(Column), findsWidgets);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('back button calls ToggleTracking when isTracking is true', (
      tester,
    ) async {
      await navigateToCarDetailView(tester, isTracking: true);
      verify(() => carDetailBloc.add(const ToggleTracking())).called(2);
    });

    testWidgets(
      'back button does not call ToggleTracking when isTracking is false',
      (tester) async {
        await navigateToCarDetailView(tester, isTracking: false);
        verifyNever(() => carDetailBloc.add(const ToggleTracking()));
      },
    );

    testWidgets('onMapCreated should add MapControllerUpdated event to bloc', (
      tester,
    ) async {
      final mockController = MockGoogleMapController();

      await tester.pumpApp(
        BlocProvider.value(
          value: carDetailBloc,
          child: Scaffold(body: MapSection(car: testCar)),
        ),
      );

      final googleMapWidget = tester.widget<GoogleMap>(find.byType(GoogleMap));
      googleMapWidget.onMapCreated!(mockController);

      verify(
        () => carDetailBloc.add(any(that: isA<MapControllerUpdated>())),
      ).called(1);
    });
  });

  group('CarInfoSection', () {
    testWidgets('displays correct localized status for all states', (
      tester,
    ) async {
      await tester.pumpApp(Scaffold(body: CarInfoSection(car: testCar)));
      expect(find.text('PARKED'), findsOneWidget);

      const movingCar = Car(
        id: '1',
        name: 'Test Car',
        latitude: 0,
        longitude: 0,
        speed: 60,
        status: CarStatus.moving,
      );
      await tester.pumpApp(
        const Scaffold(body: CarInfoSection(car: movingCar)),
      );
      expect(find.text('MOVING'), findsOneWidget);

      const unknownCar = Car(
        id: '1',
        name: 'Test Car',
        latitude: 0,
        longitude: 0,
        speed: 0,
        status: CarStatus.unknown,
      );
      await tester.pumpApp(
        const Scaffold(body: CarInfoSection(car: unknownCar)),
      );
      expect(find.text('UNKNOWN'), findsOneWidget);
    });
  });

  group('TrackingButton', () {
    Future<void> pumpTrackingButton(
      WidgetTester tester, {
      required bool isTracking,
      required bool isOnline,
    }) async {
      when(
        () => carDetailBloc.state,
      ).thenReturn(CarDetailState(car: testCar, isTracking: isTracking));
      when(
        () => connectivityBloc.state,
      ).thenReturn(ConnectivityState(isOnline: isOnline));

      await tester.pumpApp(
        Scaffold(body: TrackingButton(isTracking: isTracking)),
        connectivityBloc: connectivityBloc,
        carDetailBloc: carDetailBloc,
      );
    }

    testWidgets('calls ToggleTracking when pressed and online (not tracking)', (
      tester,
    ) async {
      await pumpTrackingButton(tester, isTracking: false, isOnline: true);
      await tester.tap(find.byType(FilledButton));
      await tester.pump();
      verify(() => carDetailBloc.add(const ToggleTracking())).called(1);
    });

    testWidgets('calls ToggleTracking when pressed while tracking and online', (
      tester,
    ) async {
      await pumpTrackingButton(tester, isTracking: true, isOnline: true);
      await tester.tap(find.byType(OutlinedButton));
      await tester.pump();
      verify(() => carDetailBloc.add(const ToggleTracking())).called(1);
    });

    testWidgets('button is disabled when offline', (tester) async {
      await pumpTrackingButton(tester, isTracking: false, isOnline: false);
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.enabled, isFalse);
      await tester.tap(find.byType(FilledButton), warnIfMissed: false);
      await tester.pump();
      verifyNever(() => carDetailBloc.add(const ToggleTracking()));
    });
  });
}
