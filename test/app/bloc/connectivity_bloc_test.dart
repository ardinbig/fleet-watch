import 'dart:async';
import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fleet_watch/app/bloc/connectivity_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockConnectivity extends Mock implements Connectivity {}

class MockInternetAddress extends Mock implements InternetAddress {}

void main() {
  group('ConnectivityBloc', () {
    late MockConnectivity mockConnectivity;
    late StreamController<List<ConnectivityResult>> connectivityController;
    const waitDuration = Duration(milliseconds: 100);

    setUp(() {
      mockConnectivity = MockConnectivity();
      connectivityController = StreamController.broadcast();

      when(
        () => mockConnectivity.checkConnectivity(),
      ).thenAnswer((_) async => [ConnectivityResult.wifi]);
      when(
        () => mockConnectivity.onConnectivityChanged,
      ).thenAnswer((_) => connectivityController.stream);
    });

    tearDown(() async {
      await connectivityController.close();
    });

    blocTest<ConnectivityBloc, ConnectivityState>(
      'initial state is online',
      build: () => ConnectivityBloc(connectivity: mockConnectivity),
      verify: (bloc) {
        expect(bloc.state, equals(const ConnectivityState(isOnline: true)));
      },
    );

    group('Connectivity changes', () {
      blocTest<ConnectivityBloc, ConnectivityState>(
        'emits offline when connectivity is lost',
        build: () => ConnectivityBloc(connectivity: mockConnectivity),
        seed: () => const ConnectivityState(isOnline: true),
        setUp: () {
          when(
            () => mockConnectivity.checkConnectivity(),
          ).thenAnswer((_) async => [ConnectivityResult.none]);
        },
        act: (bloc) => connectivityController.add([ConnectivityResult.none]),
        expect: () => [const ConnectivityState(isOnline: false)],
        wait: waitDuration,
      );

      blocTest<ConnectivityBloc, ConnectivityState>(
        'emits online when wifi connectivity is restored',
        build: () => ConnectivityBloc(connectivity: mockConnectivity),
        seed: () => const ConnectivityState(isOnline: false),
        setUp: () {
          when(
            () => mockConnectivity.checkConnectivity(),
          ).thenAnswer((_) async => [ConnectivityResult.wifi]);
        },
        act: (bloc) => connectivityController.add([ConnectivityResult.wifi]),
        expect: () => [const ConnectivityState(isOnline: true)],
        wait: waitDuration,
      );

      blocTest<ConnectivityBloc, ConnectivityState>(
        'emits online when mobile connectivity is restored',
        build: () => ConnectivityBloc(connectivity: mockConnectivity),
        seed: () => const ConnectivityState(isOnline: false),
        setUp: () {
          when(
            () => mockConnectivity.checkConnectivity(),
          ).thenAnswer((_) async => [ConnectivityResult.mobile]);
        },
        act: (bloc) => connectivityController.add([ConnectivityResult.mobile]),
        expect: () => [const ConnectivityState(isOnline: true)],
        wait: waitDuration,
      );
    });

    group('Internet verification', () {
      blocTest<ConnectivityBloc, ConnectivityState>(
        'emits offline when connectivity exists but no internet',
        setUp: () {
          when(
            () => mockConnectivity.checkConnectivity(),
          ).thenThrow(const SocketException('No internet'));
        },
        build: () => ConnectivityBloc(connectivity: mockConnectivity),
        act: (bloc) => connectivityController.add([ConnectivityResult.wifi]),
        expect: () => [const ConnectivityState(isOnline: false)],
        wait: waitDuration,
      );

      blocTest<ConnectivityBloc, ConnectivityState>(
        'emits online when connectivity and internet exist',
        build: () => ConnectivityBloc(connectivity: mockConnectivity),
        act: (bloc) => connectivityController.add([ConnectivityResult.wifi]),
        expect: () => [const ConnectivityState(isOnline: true)],
        wait: waitDuration,
      );
    });

    blocTest<ConnectivityBloc, ConnectivityState>(
      'handles exceptions gracefully',
      setUp: () {
        when(() => mockConnectivity.checkConnectivity()).thenThrow(Exception());
      },
      build: () => ConnectivityBloc(connectivity: mockConnectivity),
      act: (bloc) => connectivityController.add([ConnectivityResult.wifi]),
      expect: () => [const ConnectivityState(isOnline: false)],
      wait: waitDuration,
    );

    test('close cancels subscriptions', () async {
      final connectivityBloc = ConnectivityBloc(connectivity: mockConnectivity);
      await connectivityBloc.close();
      expect(connectivityController.hasListener, isFalse);
    });
  });
}
