import 'package:fleet_api/fleet_api.dart';
import 'package:test/test.dart';

class TestFleetApi extends FleetApi {
  TestFleetApi() : super();

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

void main() {
  group('FleetApi', () {
    test('can be instantiated', () {
      expect(TestFleetApi.new, returnsNormally);
    });
  });
}
