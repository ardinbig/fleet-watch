import 'package:bloc_test/bloc_test.dart';
import 'package:fleet_repository/fleet_repository.dart';
import 'package:fleet_watch/home/bloc/home_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mocktail/mocktail.dart';

class MockFleetRepository extends Mock implements FleetRepository {}

class MockGoogleMapController extends Mock implements GoogleMapController {}

void main() {
  late FleetRepository repo;
  late GoogleMapController mapController;

  final cars = [
    const Car(
      id: 'car1',
      name: 'Test Car 1',
      latitude: 1,
      longitude: 1,
      speed: 60,
      status: CarStatus.moving,
    ),
    const Car(
      id: 'car2',
      name: 'Test Car 2',
      latitude: 2,
      longitude: 2,
      speed: 0,
      status: CarStatus.parked,
    ),
  ];

  setUp(() {
    repo = MockFleetRepository();
    mapController = MockGoogleMapController();
  });

  group('HomeBloc', () {
    test('initial state is MapViewInitial', () {
      expect(HomeBloc(repository: repo).state, MapViewInitial());
    });

    blocTest<HomeBloc, HomeState>(
      'emits [Loading, Loaded] on MapLoadCars success',
      build: () {
        when(() => repo.fetchAndCacheCars()).thenAnswer((_) async => cars);
        return HomeBloc(repository: repo);
      },
      act: (bloc) => bloc.add(MapLoadCars()),
      expect: () => [
        MapViewLoading(),
        MapViewLoaded(cars: cars, filteredCars: cars),
      ],
      verify: (_) {
        verify(() => repo.fetchAndCacheCars()).called(1);
      },
    );

    blocTest<HomeBloc, HomeState>(
      'emits [Loading, Error] on MapLoadCars failure',
      build: () {
        when(
          () => repo.fetchAndCacheCars(),
        ).thenThrow(Exception('Failed to load cars'));
        return HomeBloc(repository: repo);
      },
      act: (bloc) => bloc.add(MapLoadCars()),
      expect: () => [
        MapViewLoading(),
        const MapViewError('Exception: Failed to load cars'),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'emits [MapViewError] when MapUpdateCars fails',
      seed: () => MapViewLoaded(cars: cars, filteredCars: cars),
      build: () {
        when(
          () => repo.getCachedCars(),
        ).thenThrow(Exception('Failed to get cached cars'));
        return HomeBloc(repository: repo);
      },
      act: (bloc) => bloc.add(MapUpdateCars()),
      expect: () => [
        const MapViewError('Exception: Failed to get cached cars'),
      ],
      verify: (_) {
        verify(() => repo.getCachedCars()).called(1);
      },
    );

    blocTest<HomeBloc, HomeState>(
      'updates cars with MapUpdateCars',
      seed: () => MapViewLoaded(cars: cars, filteredCars: cars),
      build: () {
        final updatedCars = [...cars];
        updatedCars[0] = const Car(
          id: 'car1',
          name: 'Updated Car 1',
          latitude: 1.5,
          longitude: 1.5,
          speed: 75,
          status: CarStatus.moving,
        );
        when(() => repo.getCachedCars()).thenAnswer((_) async => updatedCars);
        return HomeBloc(repository: repo);
      },
      act: (bloc) => bloc.add(MapUpdateCars()),
      expect: () => [
        isA<MapViewLoaded>().having(
          (state) => state.cars.first.name,
          'first car name',
          'Updated Car 1',
        ),
      ],
    );

    test(
      'timer periodically adds MapUpdateCars events',
      () async {
        when(() => repo.fetchAndCacheCars()).thenAnswer((_) async => cars);
        var callCount = 0;
        when(() => repo.getCachedCars()).thenAnswer((_) async {
          callCount++;
          return cars;
        });

        final bloc = HomeBloc(repository: repo)..add(MapLoadCars());
        await Future<void>.delayed(const Duration(seconds: 6));

        verify(() => repo.fetchAndCacheCars()).called(1);
        expect(
          callCount,
          greaterThan(0),
          reason: 'Timer should have triggered at least one update',
        );

        await bloc.close();
      },
      timeout: const Timeout(Duration(seconds: 10)),
    );

    blocTest<HomeBloc, HomeState>(
      'updates controller with MapControllerUpdated',
      seed: () => MapViewLoaded(cars: cars, filteredCars: cars),
      build: () => HomeBloc(repository: repo),
      act: (bloc) => bloc.add(MapControllerUpdated(mapController)),
      expect: () => [
        MapViewLoaded(
          cars: cars,
          filteredCars: cars,
          controller: mapController,
        ),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'filters cars by search query',
      seed: () => MapViewLoaded(cars: cars, filteredCars: cars),
      build: () => HomeBloc(repository: repo),
      act: (bloc) => bloc.add(const MapSearchQueryChanged('Car 1')),
      expect: () => [
        MapViewLoaded(
          cars: cars,
          filteredCars: [cars[0]],
          searchQuery: 'Car 1',
        ),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'filters cars by status',
      seed: () => MapViewLoaded(cars: cars, filteredCars: cars),
      build: () => HomeBloc(repository: repo),
      act: (bloc) => bloc.add(const MapFilterStatusChanged('parked')),
      expect: () => [
        MapViewLoaded(
          cars: cars,
          filteredCars: [cars[1]],
          filterStatus: 'parked',
        ),
      ],
    );

    test('cancels timer when closed', () async {
      when(() => repo.fetchAndCacheCars()).thenAnswer((_) async => cars);
      final bloc = HomeBloc(repository: repo)..add(MapLoadCars());
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await bloc.close();
      expect(bloc.isClosed, true);
    });
  });
}
