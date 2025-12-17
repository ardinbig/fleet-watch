import 'package:fleet_api/fleet_api.dart';
import 'package:test/test.dart';

void main() {
  group('Car', () {
    Car createSubject({
      String id = '1',
      String name = 'Car 1',
      double latitude = 0.0,
      double longitude = 0.0,
      double speed = 0.0,
      CarStatus status = CarStatus.parked,
    }) {
      return Car(
        id: id,
        name: name,
        latitude: latitude,
        longitude: longitude,
        speed: speed,
        status: status,
      );
    }

    group('constructor', () {
      test('works correctly', () {
        expect(createSubject, returnsNormally);
      });

      test('supports value equality', () {
        expect(createSubject(), equals(createSubject()));
        expect(createSubject().hashCode, equals(createSubject().hashCode));
        expect(createSubject().toString(), equals(createSubject().toString()));
      });

      test('props are correct', () {
        expect(
          createSubject().props,
          equals(['1', 'Car 1', 0.0, 0.0, 0.0, CarStatus.parked]),
        );
      });
    });

    group('fromJson', () {
      test('works correctly', () {
        final json = {
          'id': '1',
          'name': 'Car 1',
          'latitude': 0.0,
          'longitude': 0.0,
          'speed': 0.0,
          'status': 'parked',
        };
        expect(Car.fromJson(json), createSubject());
      });
    });

    group('toJson', () {
      test('works correctly', () {
        final car = createSubject();
        final json = car.toJson();
        expect(json['id'], equals(car.id));
        expect(json['name'], equals(car.name));
        expect(json['latitude'], equals(car.latitude));
        expect(json['longitude'], equals(car.longitude));
        expect(json['speed'], equals(car.speed));
        expect(json['status'], equals(car.status.name));
      });
    });
  });
}
