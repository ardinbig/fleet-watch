import 'package:bloc_test/bloc_test.dart';
import 'package:fake_async/fake_async.dart';
import 'package:fleet_repository/fleet_repository.dart';
import 'package:fleet_watch/car_detail/bloc/car_detail_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mocktail/mocktail.dart';

class MockFleetRepository extends Mock implements FleetRepository {}

class MockGoogleMapController extends Mock implements GoogleMapController {}

class FakeCameraUpdate extends Fake implements CameraUpdate {}

void main() {
  late CarDetailBloc carDetailBloc;
  late MockFleetRepository mockRepository;
  late Car mockCar;
  late Car updatedMockCar;
  late Car secondUpdateCar;

  setUpAll(() {
    registerFallbackValue(FakeCameraUpdate());
  });

  setUp(() {
    mockRepository = MockFleetRepository();
    carDetailBloc = CarDetailBloc(repository: mockRepository);

    mockCar = const Car(
      id: '1',
      name: 'Test Car',
      latitude: 37.4220,
      longitude: -122.0841,
      speed: 0,
      status: CarStatus.parked,
    );

    updatedMockCar = const Car(
      id: '1',
      name: 'Test Car',
      latitude: 37.4230,
      longitude: -122.0851,
      speed: 30,
      status: CarStatus.moving,
    );

    secondUpdateCar = const Car(
      id: '1',
      name: 'Test Car',
      latitude: 37.4240,
      longitude: -122.0861,
      speed: 45,
      status: CarStatus.moving,
    );
  });

  tearDown(() {
    carDetailBloc.close();
  });

  test('initial state should be CarDetailState.initial()', () {
    expect(carDetailBloc.state, equals(CarDetailState.initial()));
  });

  group('Bloc events', () {
    blocTest<CarDetailBloc, CarDetailState>(
      'emits state with car when StartTrackingCar is added',
      build: () => carDetailBloc,
      act: (bloc) => bloc.add(StartTrackingCar(mockCar)),
      expect: () => [CarDetailState.initial().copyWith(car: mockCar)],
    );

    blocTest<CarDetailBloc, CarDetailState>(
      'updates isTracking when ToggleTracking is added',
      build: () {
        when(
          () => mockRepository.fetchAndCacheCarDetails(1),
        ).thenAnswer((_) async => updatedMockCar);
        return carDetailBloc;
      },
      seed: () => CarDetailState.initial().copyWith(car: mockCar),
      act: (bloc) => bloc.add(const ToggleTracking()),
      expect: () => [
        CarDetailState.initial().copyWith(car: mockCar, isTracking: true),
      ],
    );
  });

  test('creates timer that fetches car updates periodically', () {
    return FakeAsync().run((clock) {
      when(
        () => mockRepository.fetchAndCacheCarDetails(1),
      ).thenAnswer((_) async => updatedMockCar);
      final bloc = CarDetailBloc(repository: mockRepository)
        ..add(StartTrackingCar(mockCar));

      // Process initial events
      clock.flushMicrotasks();

      // Begin tracking (start timer)
      bloc.add(const ToggleTracking());
      clock.flushMicrotasks();
      expect(bloc.state.isTracking, true);

      // First timer cycle
      clock
        ..elapse(const Duration(seconds: 5))
        ..flushMicrotasks();
      verify(() => mockRepository.fetchAndCacheCarDetails(1)).called(1);
      expect(bloc.state.car, equals(updatedMockCar));

      // Setup for second cycle
      reset(mockRepository);
      when(
        () => mockRepository.fetchAndCacheCarDetails(1),
      ).thenAnswer((_) async => secondUpdateCar);

      // Second timer cycle
      clock
        ..elapse(const Duration(seconds: 5))
        ..flushMicrotasks();
      verify(() => mockRepository.fetchAndCacheCarDetails(1)).called(1);
      expect(bloc.state.car, equals(secondUpdateCar));

      // Stop tracking
      bloc.add(const ToggleTracking());
      clock.flushMicrotasks();
      expect(bloc.state.isTracking, false);

      // Verify no more calls when tracking is off
      reset(mockRepository);
      clock
        ..elapse(const Duration(seconds: 5))
        ..flushMicrotasks();
      verifyNoMoreInteractions(mockRepository);

      // Clean up resources
      bloc.close();
    });
  });

  group('Car location updates', () {
    late MockGoogleMapController mockMapController;

    setUp(() {
      mockMapController = MockGoogleMapController();
      when(
        () => mockMapController.animateCamera(any<CameraUpdate>()),
      ).thenAnswer((_) async {});
    });

    blocTest<CarDetailBloc, CarDetailState>(
      'updates car and animates camera when car location is updated',
      build: () => carDetailBloc,
      seed: () => CarDetailState.initial().copyWith(
        car: mockCar,
        mapController: mockMapController,
      ),
      act: (bloc) => bloc.add(UpdateCarLocation(updatedMockCar)),
      expect: () => [
        CarDetailState.initial().copyWith(
          car: updatedMockCar,
          mapController: mockMapController,
        ),
      ],
      verify: (_) {
        verify(
          () => mockMapController.animateCamera(any<CameraUpdate>()),
        ).called(1);
      },
    );

    blocTest<CarDetailBloc, CarDetailState>(
      'updates mapController when MapControllerUpdated is added',
      build: () => carDetailBloc,
      act: (bloc) => bloc.add(MapControllerUpdated(mockMapController)),
      expect: () => [
        isA<CarDetailState>().having(
          (state) => state.mapController,
          'mapController',
          isNotNull,
        ),
      ],
    );
  });

  test('disposes resources when closed', () async {
    final mockController = MockGoogleMapController();
    when(mockController.dispose).thenAnswer((_) async {});

    final bloc = CarDetailBloc(repository: mockRepository)
      ..add(MapControllerUpdated(mockController));
    await pumpEventQueue();

    await bloc.close();
    verify(mockController.dispose).called(1);
  });
}
