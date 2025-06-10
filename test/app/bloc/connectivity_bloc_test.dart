import 'dart:async';
import 'dart:io' show SocketException;

import 'package:bloc_test/bloc_test.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fleet_watch/app/bloc/connectivity_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockConnectivity extends Mock implements Connectivity {}

class MockInternetChecker extends Mock implements InternetChecker {}

void main() {
  late MockConnectivity mockConnectivity;
  late MockInternetChecker mockInternetChecker;
  late StreamController<List<ConnectivityResult>> connectivityController;
  const waitDuration = Duration(milliseconds: 100);

  setUp(() {
    mockConnectivity = MockConnectivity();
    mockInternetChecker = MockInternetChecker();
    connectivityController = StreamController.broadcast();
    when(
      () => mockConnectivity.checkConnectivity(),
    ).thenAnswer((_) async => [ConnectivityResult.wifi]);
    when(
      () => mockConnectivity.onConnectivityChanged,
    ).thenAnswer((_) => connectivityController.stream);
    when(
      () => mockInternetChecker.checkInternet(),
    ).thenAnswer((_) async => true);
  });

  tearDown(() async {
    await connectivityController.close();
  });

  group('ConnectivityBloc', () {
    blocTest<ConnectivityBloc, ConnectivityState>(
      'initial state is updated to online after connectivity check',
      build: () => ConnectivityBloc(connectivity: mockConnectivity),
      seed: () => const ConnectivityState(isOnline: false),
      act: (bloc) async {
        await Future<void>.delayed(waitDuration * 0.5);
      },
      expect: () => const [ConnectivityState(isOnline: true)],
      wait: waitDuration,
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
        expect: () => const [ConnectivityState(isOnline: false)],
        wait: waitDuration,
      );

      blocTest<ConnectivityBloc, ConnectivityState>(
        'emits online when wifi connectivity is restored',
        build: () => ConnectivityBloc(connectivity: mockConnectivity),
        seed: () => const ConnectivityState(isOnline: false),
        act: (bloc) => connectivityController.add([ConnectivityResult.wifi]),
        expect: () => const [ConnectivityState(isOnline: true)],
        wait: waitDuration,
      );

      blocTest<ConnectivityBloc, ConnectivityState>(
        'emits online when mobile connectivity is restored',
        build: () => ConnectivityBloc(connectivity: mockConnectivity),
        seed: () => const ConnectivityState(isOnline: false),
        act: (bloc) => connectivityController.add([ConnectivityResult.mobile]),
        expect: () => const [ConnectivityState(isOnline: true)],
        wait: waitDuration,
      );

      blocTest<ConnectivityBloc, ConnectivityState>(
        'emits online when only mobile connectivity is available (no WiFi)',
        build: () => ConnectivityBloc(connectivity: mockConnectivity),
        seed: () => const ConnectivityState(isOnline: false),
        setUp: () {
          when(
            () => mockConnectivity.checkConnectivity(),
          ).thenAnswer((_) async => [ConnectivityResult.mobile]);
        },
        act: (bloc) => connectivityController.add([ConnectivityResult.mobile]),
        expect: () => const [ConnectivityState(isOnline: true)],
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
        expect: () => const [ConnectivityState(isOnline: false)],
        wait: waitDuration,
      );

      blocTest<ConnectivityBloc, ConnectivityState>(
        'emits online when connectivity and internet exist',
        build: () => ConnectivityBloc(connectivity: mockConnectivity),
        act: (bloc) => connectivityController.add([ConnectivityResult.wifi]),
        expect: () => const [ConnectivityState(isOnline: true)],
        wait: waitDuration,
      );

      blocTest<ConnectivityBloc, ConnectivityState>(
        'emits offline when SocketException occurs during internet check',
        build: () => ConnectivityBloc(
          connectivity: mockConnectivity,
          internetChecker: mockInternetChecker,
        ),
        seed: () => const ConnectivityState(isOnline: true),
        setUp: () {
          when(
            () => mockInternetChecker.checkInternet(),
          ).thenAnswer((_) async => false);
        },
        act: (bloc) => connectivityController.add([ConnectivityResult.wifi]),
        expect: () => const [ConnectivityState(isOnline: false)],
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
      expect: () => const [ConnectivityState(isOnline: false)],
      wait: waitDuration,
    );

    test('close cancels subscriptions', () async {
      final connectivityBloc = ConnectivityBloc(connectivity: mockConnectivity);
      await Future<void>.delayed(waitDuration);
      await connectivityBloc.close();
      expect(connectivityController.hasListener, isFalse);
    });
  });
}
