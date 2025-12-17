import 'package:fleet_watch/home/bloc/home_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mocktail/mocktail.dart';

class MockGoogleMapController extends Mock implements GoogleMapController {}

void main() {
  group('HomeEvent', () {
    group('MapLoadCars', () {
      test('supports value equality', () {
        expect(MapLoadCars(), equals(MapLoadCars()));
      });

      test('props are empty', () {
        expect(MapLoadCars().props, isEmpty);
      });
    });

    group('MapUpdateCars', () {
      test('supports value equality', () {
        expect(MapUpdateCars(), equals(MapUpdateCars()));
      });

      test('props are empty', () {
        expect(MapUpdateCars().props, isEmpty);
      });
    });

    group('MapControllerUpdated', () {
      test('supports value equality', () {
        final controller1 = MockGoogleMapController();
        final controller2 = MockGoogleMapController();

        expect(
          MapControllerUpdated(controller1),
          equals(MapControllerUpdated(controller1)),
        );
        expect(
          MapControllerUpdated(controller1),
          isNot(equals(MapControllerUpdated(controller2))),
        );
      });

      test('props contains controller', () {
        final controller = MockGoogleMapController();
        expect(MapControllerUpdated(controller).props, equals([controller]));
      });
    });

    group('MapSearchQueryChanged', () {
      test('supports value equality', () {
        expect(
          const MapSearchQueryChanged('query'),
          equals(const MapSearchQueryChanged('query')),
        );

        expect(
          const MapSearchQueryChanged('query1'),
          isNot(equals(const MapSearchQueryChanged('query2'))),
        );
      });

      test('props contains query', () {
        const query = 'test query';
        expect(const MapSearchQueryChanged(query).props, equals([query]));
      });
    });

    group('MapFilterStatusChanged', () {
      test('supports value equality', () {
        expect(
          const MapFilterStatusChanged('moving'),
          equals(const MapFilterStatusChanged('moving')),
        );

        expect(
          const MapFilterStatusChanged('moving'),
          isNot(equals(const MapFilterStatusChanged('parked'))),
        );
      });

      test('props contains status', () {
        const status = 'moving';
        expect(const MapFilterStatusChanged(status).props, equals([status]));
      });
    });
  });
}
