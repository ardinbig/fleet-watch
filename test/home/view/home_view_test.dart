import 'package:bloc_test/bloc_test.dart';
import 'package:fleet_repository/fleet_repository.dart';
import 'package:fleet_watch/car_detail/view/car_detail_page.dart';
import 'package:fleet_watch/home/home.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/helpers.dart';

class MockHomeBloc extends MockBloc<HomeEvent, HomeState> implements HomeBloc {}

class MockFleetRepository extends Mock implements FleetRepository {}

class MockGoogleMapController extends Mock implements GoogleMapController {}

class FakeHomeEvent extends Fake implements HomeEvent {}

void main() {
  late MockHomeBloc homeBloc;
  late MockFleetRepository fleetRepository;

  final testCars = [
    const Car(
      id: '1',
      name: 'Test Car 1',
      status: CarStatus.parked,
      latitude: 1,
      longitude: 1,
      speed: 0,
    ),
    const Car(
      id: '2',
      name: 'Test Car 2',
      status: CarStatus.moving,
      latitude: 2,
      longitude: 2,
      speed: 20,
    ),
  ];

  setUpAll(() {
    registerFallbackValue(FakeHomeEvent());
  });

  setUp(() {
    homeBloc = MockHomeBloc();
    fleetRepository = MockFleetRepository();
  });

  testWidgets('renders GoogleMap', (tester) async {
    when(() => homeBloc.state).thenReturn(MapViewInitial());
    await tester.pumpApp(
      const HomeView(),
      fleetRepository: fleetRepository,
      homeBloc: homeBloc,
    );
    expect(find.byType(GoogleMap), findsOneWidget);
  });

  testWidgets('sends MapControllerUpdated event when map is created', (
    tester,
  ) async {
    when(() => homeBloc.state).thenReturn(MapViewInitial());
    await tester.pumpApp(
      const HomeView(),
      fleetRepository: fleetRepository,
      homeBloc: homeBloc,
    );

    final googleMapFinder = find.byType(GoogleMap);
    expect(googleMapFinder, findsOneWidget);

    final googleMapWidget = tester.widget<GoogleMap>(googleMapFinder);
    final mockController = MockGoogleMapController();
    googleMapWidget.onMapCreated!(mockController);

    verify(
      () => homeBloc.add(any(that: isA<MapControllerUpdated>())),
    ).called(1);
  });

  testWidgets('creates markers when state is MapViewLoaded', (tester) async {
    when(
      () => homeBloc.state,
    ).thenReturn(MapViewLoaded(cars: testCars, filteredCars: testCars));

    await tester.pumpApp(
      const HomeView(),
      fleetRepository: fleetRepository,
      homeBloc: homeBloc,
    );

    final googleMapFinder = find.byType(GoogleMap);
    expect(googleMapFinder, findsOneWidget);
    final googleMapWidget = tester.widget<GoogleMap>(googleMapFinder);
    expect(googleMapWidget.markers.isEmpty, isFalse);
  });

  testWidgets('initializes camera position based on first car when available', (
    tester,
  ) async {
    final testCars = [
      const Car(
        id: '1',
        name: 'Test Car 1',
        status: CarStatus.parked,
        latitude: 37.4219999,
        longitude: -122.0840575,
        speed: 0,
      ),
    ];
    when(
      () => homeBloc.state,
    ).thenReturn(MapViewLoaded(cars: testCars, filteredCars: testCars));

    await tester.pumpApp(
      const HomeView(),
      fleetRepository: fleetRepository,
      homeBloc: homeBloc,
    );

    final googleMapFinder = find.byType(GoogleMap);
    final googleMapWidget = tester.widget<GoogleMap>(googleMapFinder);

    expect(googleMapWidget.initialCameraPosition.target.latitude, 37.4219999);
    expect(
      googleMapWidget.initialCameraPosition.target.longitude,
      -122.0840575,
    );
    expect(googleMapWidget.initialCameraPosition.zoom, 14);
  });

  testWidgets('defaults camera position when no cars available', (
    tester,
  ) async {
    when(
      () => homeBloc.state,
    ).thenReturn(const MapViewLoaded(cars: [], filteredCars: []));

    await tester.pumpApp(
      const HomeView(),
      fleetRepository: fleetRepository,
      homeBloc: homeBloc,
    );

    final googleMapFinder = find.byType(GoogleMap);
    final googleMapWidget = tester.widget<GoogleMap>(googleMapFinder);

    expect(googleMapWidget.initialCameraPosition.target.latitude, 0);
    expect(googleMapWidget.initialCameraPosition.target.longitude, 0);
    expect(googleMapWidget.initialCameraPosition.zoom, 14);
  });

  testWidgets('navigates to CarDetailPage when marker is tapped', (
    tester,
  ) async {
    when(
      () => homeBloc.state,
    ).thenReturn(MapViewLoaded(cars: testCars, filteredCars: testCars));

    await tester.pumpApp(
      const HomeView(),
      fleetRepository: fleetRepository,
      homeBloc: homeBloc,
    );

    final googleMapFinder = find.byType(GoogleMap);
    final googleMapWidget = tester.widget<GoogleMap>(googleMapFinder);
    final firstMarker = googleMapWidget.markers.first;

    firstMarker.onTap!();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(CarDetailPage), findsOneWidget);

    final carDetailPage = tester.widget<CarDetailPage>(
      find.byType(CarDetailPage),
    );
    expect(carDetailPage.car.id, testCars.first.id);
    expect(carDetailPage.car.name, testCars.first.name);
    expect(carDetailPage.repository, fleetRepository);
  });
}
