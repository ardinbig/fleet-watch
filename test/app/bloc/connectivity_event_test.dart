import 'package:fleet_watch/app/bloc/connectivity_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ConnectivityEvent', () {
    group('ConnectivityStatusChanged', () {
      test('props contains isOnline', () {
        const isOnline = true;
        const event = ConnectivityStatusChanged(isOnline: isOnline);

        final props = event.props;

        expect(props, [isOnline]);
        expect(props.length, 1);
      });

      test('equality works correctly', () {
        const event1 = ConnectivityStatusChanged(isOnline: true);
        const event2 = ConnectivityStatusChanged(isOnline: true);
        const event3 = ConnectivityStatusChanged(isOnline: false);

        expect(event1, equals(event2));
        expect(event1, isNot(equals(event3)));
      });
    });
  });
}
