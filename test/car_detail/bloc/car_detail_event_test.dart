import 'package:fleet_repository/fleet_repository.dart';
import 'package:fleet_watch/car_detail/bloc/car_detail_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mocktail/mocktail.dart';

class MockGoogleMapController extends Mock implements GoogleMapController {}

void main() {
  late Car testCar;
  late Car differentCar;
  late GoogleMapController mockController;
  late GoogleMapController secondMockController;

  setUp(() {
    mockController = MockGoogleMapController();
    secondMockController = MockGoogleMapController();

    testCar = const Car(
      id: '1',
      name: 'Test Car',
      latitude: 37.4220,
      longitude: -122.0841,
      speed: 30,
      status: CarStatus.moving,
    );

    differentCar = const Car(
      id: '2',
      name: 'Another Car',
      latitude: 38.4220,
      longitude: -122.0841,
      speed: 0,
      status: CarStatus.parked,
    );
  });

  group('CarDetailEvent', () {
    group('StartTrackingCar', () {
      test('supports value equality', () {
        expect(StartTrackingCar(testCar), equals(StartTrackingCar(testCar)));
      });

      test('props contains car', () {
        expect(StartTrackingCar(testCar).props, equals([testCar]));
      });

      test('different cars yield different events', () {
        expect(
          StartTrackingCar(testCar),
          isNot(equals(StartTrackingCar(differentCar))),
        );
      });
    });

    group('ToggleTracking', () {
      test('supports value equality', () {
        expect(const ToggleTracking(), equals(const ToggleTracking()));
      });

      test('props is empty', () {
        expect(const ToggleTracking().props, isEmpty);
      });
    });

    group('UpdateCarLocation', () {
      test('supports value equality', () {
        expect(UpdateCarLocation(testCar), equals(UpdateCarLocation(testCar)));
      });

      test('props contains car', () {
        expect(UpdateCarLocation(testCar).props, equals([testCar]));
      });

      test('different cars yield different events', () {
        const updatedCar = Car(
          id: '1',
          name: 'Test Car',
          latitude: 37.5220,
          longitude: -122.1841,
          speed: 45,
          status: CarStatus.moving,
        );
        expect(
          UpdateCarLocation(testCar),
          isNot(equals(const UpdateCarLocation(updatedCar))),
        );
      });
    });

    group('MapControllerUpdated', () {
      test('supports value equality', () {
        expect(
          MapControllerUpdated(mockController),
          equals(MapControllerUpdated(mockController)),
        );
      });

      test('props contains controller', () {
        expect(
          MapControllerUpdated(mockController).props,
          equals([mockController]),
        );
      });

      test('different controllers yield different events', () {
        expect(
          MapControllerUpdated(mockController),
          isNot(equals(MapControllerUpdated(secondMockController))),
        );
      });
    });
  });
}
