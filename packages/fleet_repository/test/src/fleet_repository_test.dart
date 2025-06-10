import 'package:fleet_repository/fleet_repository.dart';
import 'package:hive_fleet_api/hive_fleet_api.dart';
import 'package:mock_fleet_api/mock_fleet_api.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockMockFleetApi extends Mock implements MockFleetApi {}

class MockHiveFleetApi extends Mock implements HiveFleetApi {}

class MockBox<T> extends Mock implements Box<T> {}

class FakeCar extends Fake implements Car {}

void main() {
  late FleetRepository repository;
  late MockMockFleetApi remoteApi;
  late MockHiveFleetApi localApi;
  late MockBox<Car> box;

  final cars = [
    const Car(
      id: '1',
      name: 'Car 1',
      latitude: 37.7749,
      longitude: -122.4194,
      speed: 60,
      status: CarStatus.moving,
    ),
    const Car(
      id: '2',
      name: 'Car 2',
      latitude: 37.7750,
      longitude: -122.4195,
      speed: 0,
      status: CarStatus.parked,
    ),
    const Car(
      id: '3',
      name: 'Car 3',
      latitude: 37.7751,
      longitude: -122.4196,
      speed: 0,
      status: CarStatus.parked,
    ),
  ];

  const car = Car(
    id: '1',
    name: 'Car 1',
    latitude: 37.7749,
    longitude: -122.4194,
    speed: 60,
    status: CarStatus.moving,
  );

  void setupMocks() {
    // Local API mocks
    when(() => localApi.box).thenReturn(box);
    when(() => localApi.fetchCars()).thenAnswer((_) async => cars);
    when(() => localApi.saveCar(any())).thenAnswer((_) async {});
    when(
      () => localApi.watchAllCars(pollInterval: any(named: 'pollInterval')),
    ).thenAnswer((_) => Stream.value(cars));
    when(() => localApi.fetchCarDetails(any())).thenAnswer((_) async => car);
    when(
      () => localApi.watchCarLocation(
        any(),
        pollInterval: any(named: 'pollInterval'),
      ),
    ).thenAnswer((_) => Stream.value(car));
    when(() => localApi.close()).thenAnswer((_) async {});

    when(() => remoteApi.fetchCars()).thenAnswer((_) async => cars);
    when(() => remoteApi.fetchCarDetails(any())).thenAnswer((_) async => car);
    when(() => remoteApi.close()).thenAnswer((_) async {});

    when(() => box.put(dynamic, any())).thenAnswer((_) async {});
  }

  setUpAll(() {
    registerFallbackValue(FakeCar());
    FleetRepository.hiveFleetApiFactory = MockHiveFleetApi.new;
  });

  setUp(() {
    remoteApi = MockMockFleetApi();
    localApi = MockHiveFleetApi();
    box = MockBox<Car>();

    setupMocks();

    repository = FleetRepository(remoteApi: remoteApi, localApi: localApi);
  });

  group('FleetRepository', () {
    group('Constructor', () {
      test('works properly with explicit dependencies', () {
        expect(repository, isNotNull);
        expect(repository.remoteApiType, equals('MockMockFleetApi'));
        expect(repository.localApiType, equals('MockHiveFleetApi'));
      });

      test('creates default dependencies when none provided', () {
        final mockHiveFleetApi = MockHiveFleetApi();
        when(() => mockHiveFleetApi.box).thenReturn(box);
        when(mockHiveFleetApi.close).thenAnswer((_) async {});

        FleetRepository.hiveFleetApiFactory = () => mockHiveFleetApi;

        final defaultRepo = FleetRepository();
        expect(defaultRepo, isNotNull);
        expect(defaultRepo.remoteApiType, equals('MockFleetApi'));
        expect(defaultRepo.localApiType, equals('MockHiveFleetApi'));
        defaultRepo.dispose();
      });
    });

    group('Car fetching and caching', () {
      test('fetchAndCacheCars gets from remote and caches locally', () async {
        final result = await repository.fetchAndCacheCars();

        expect(result, equals(cars));
        verify(() => remoteApi.fetchCars()).called(1);
        verify(() => localApi.saveCar(any())).called(cars.length);
      });

      test('fetchAndCacheCars falls back to cache on remote failure', () async {
        when(() => remoteApi.fetchCars()).thenThrow(Exception('Network error'));

        final result = await repository.fetchAndCacheCars();

        expect(result, equals(cars));
        verify(() => remoteApi.fetchCars()).called(1);
        verify(() => localApi.fetchCars()).called(1);
        verifyNever(() => localApi.saveCar(any()));
      });

      test('filterCarsByStatus returns filtered cached cars', () async {
        final result = await repository.filterCarsByStatus(CarStatus.parked);

        expect(result.length, 2, reason: 'Should have exactly 2 parked cars');
        expect(
          result.every((car) => car.status == CarStatus.parked),
          isTrue,
          reason: 'All cars should have parked status',
        );
        verify(() => localApi.fetchCars()).called(1);
      });

      test('getCachedCars fetches from local cache', () async {
        final result = await repository.getCachedCars();
        expect(result, equals(cars));
        verify(() => localApi.fetchCars()).called(1);
      });
    });

    group('Car streaming', () {
      test('watchCachedCars streams cars from local cache', () {
        expect(repository.watchCachedCars(), emits(cars));
        verify(() => localApi.watchAllCars()).called(1);
      });

      test('watchCachedCars passes custom poll interval', () {
        const customInterval = Duration(seconds: 5);
        repository.watchCachedCars(pollInterval: customInterval);
        verify(
          () => localApi.watchAllCars(pollInterval: customInterval),
        ).called(1);
      });

      test('watchCachedCarLocation streams car from local cache', () {
        expect(repository.watchCachedCarLocation(1), emits(car));
        verify(() => localApi.watchCarLocation(1)).called(1);
      });

      test('watchCachedCarLocation passes custom poll interval', () {
        const customInterval = Duration(seconds: 5);
        repository.watchCachedCarLocation(1, pollInterval: customInterval);
        verify(
          () => localApi.watchCarLocation(1, pollInterval: customInterval),
        ).called(1);
      });
    });

    group('Car details', () {
      test(
        'fetchAndCacheCarDetails gets from remote and caches locally',
        () async {
          final result = await repository.fetchAndCacheCarDetails(1);

          expect(result, equals(car));
          verify(() => remoteApi.fetchCarDetails(1)).called(1);
          verify(() => localApi.saveCar(car)).called(1);
        },
      );

      test(
        'fetchAndCacheCarDetails falls back to cache on remote failure',
        () async {
          when(
            () => remoteApi.fetchCarDetails(any()),
          ).thenThrow(Exception('Network error'));

          final result = await repository.fetchAndCacheCarDetails(1);

          expect(result, equals(car));
          verify(() => remoteApi.fetchCarDetails(1)).called(1);
          verify(() => localApi.fetchCarDetails(1)).called(1);
          verifyNever(() => localApi.saveCar(any()));
        },
      );

      test('getCachedCarDetails fetches from local cache', () async {
        final result = await repository.getCachedCarDetails(1);
        expect(result, equals(car));
        verify(() => localApi.fetchCarDetails(1)).called(1);
      });
    });

    test('dispose closes both remote and local api clients', () {
      repository.dispose();
      verify(() => remoteApi.close()).called(1);
      verify(() => localApi.close()).called(1);
    });
  });
}
