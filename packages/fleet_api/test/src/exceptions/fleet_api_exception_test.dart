import 'package:fleet_api/fleet_api.dart';
import 'package:test/test.dart';

void main() {
  group('FleetApiException', () {
    test('can be instantiated', () {
      expect(
        FleetApiException('error message'),
        isA<FleetApiException>(),
      );
    });

    test('toString returns correct message without code', () {
      const message = 'test error';
      final exception = FleetApiException(message);

      expect(
        exception.toString(),
        equals('FleetApiException(message: $message)'),
      );
    });

    test('toString returns correct message with code', () {
      const message = 'test error';
      const code = 404;
      final exception = FleetApiException(message, code);

      expect(
        exception.toString(),
        equals('FleetApiException(code: $code, message: $message)'),
      );
    });

    test('props are correct', () {
      const message = 'test error';
      const code = 404;
      final exception = FleetApiException(message, code);

      expect(exception.message, equals(message));
      expect(exception.code, equals(code));
    });
  });
}
