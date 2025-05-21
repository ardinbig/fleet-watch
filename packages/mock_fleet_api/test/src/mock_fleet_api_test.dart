//
// ignore_for_file: inference_failure_on_function_invocation

import 'package:dio/dio.dart';
import 'package:fleet_api/fleet_api.dart';
import 'package:mock_fleet_api/mock_fleet_api.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockDio extends Mock implements Dio {}

class MockResponse extends Mock implements Response<dynamic> {}

class FakeDioOptions extends Fake implements BaseOptions {}

class FakeRequestOptions extends Fake implements RequestOptions {}

void main() {
  group('MockFleetApi', () {
    late MockFleetApi api;
    late MockDio dio;

    final mockCarsJson = [
      {
        'id': '1',
        'name': 'Test Car 1',
        'latitude': 37.7749,
        'longitude': -122.4194,
        'speed': 60,
        'status': 'moving',
      },
      {
        'id': '2',
        'name': 'Test Car 2',
        'latitude': 37.7750,
        'longitude': -122.4195,
        'speed': 0,
        'status': 'parked',
      },
    ];

    final mockCarJson = {
      'id': '1',
      'name': 'Test Car 1',
      'latitude': 37.7749,
      'longitude': -122.4194,
      'speed': 60,
      'status': 'moving',
    };

    setUpAll(() {
      registerFallbackValue(FakeDioOptions());
      registerFallbackValue(FakeRequestOptions());
    });

    setUp(() {
      dio = MockDio();
      when(() => dio.options).thenReturn(BaseOptions());
      when(() => dio.interceptors).thenReturn(Interceptors());
      api = MockFleetApi(
        dio: dio,
        baseUrl: 'http://test.com',
        pollInterval: const Duration(milliseconds: 100),
      );
    });

    test('initializes with correct configuration', () {
      verify(() => dio.options);
      verify(() => dio.interceptors);
    });

    group('constructor', () {
      test('creates internal Dio instance when none provided', () {
        final api = MockFleetApi(baseUrl: 'http://test.com');
        expect(api, isA<FleetApi>());
        api.close();
      });

      test('uses provided Dio instance', () {
        final dio = MockDio();
        when(() => dio.options).thenReturn(BaseOptions());
        when(() => dio.interceptors).thenReturn(Interceptors());
        final api = MockFleetApi(dio: dio, baseUrl: 'http://test.com');
        expect(api, isA<FleetApi>());
      });
    });

    group('fetchCars', () {
      test('makes correct API request', () async {
        final mockResponse = MockResponse();
        when(() => mockResponse.statusCode).thenReturn(200);
        when(() => mockResponse.data).thenReturn(mockCarsJson);
        when(() => dio.get('http://test.com/cars'))
            .thenAnswer((_) async => mockResponse);
        await api.fetchCars();
        verify(() => dio.get('http://test.com/cars')).called(1);
      });

      test('returns parsed car data', () async {
        final mockResponse = MockResponse();
        when(() => mockResponse.statusCode).thenReturn(200);
        when(() => mockResponse.data).thenReturn(mockCarsJson);
        when(() => dio.get('http://test.com/cars'))
            .thenAnswer((_) async => mockResponse);
        final cars = await api.fetchCars();
        expect(cars.length, 2);
        expect(cars[0].id, '1');
        expect(cars[0].status, CarStatus.moving);
      });

      test('handles error response correctly', () async {
        final mockResponse = MockResponse();
        when(() => mockResponse.statusCode).thenReturn(404);
        when(() => mockResponse.data).thenReturn({'error': 'Not found'});
        when(() => dio.get('http://test.com/cars'))
            .thenAnswer((_) async => mockResponse);
        expect(
          () => api.fetchCars(),
          throwsA(isA<FleetApiException>().having((e) => e.code, 'code', 404)),
        );
        verify(() => dio.get('http://test.com/cars')).called(1);
      });

      test('throws FleetApiException with status code on non-200 response',
          () async {
        final mockResponse = MockResponse();
        when(() => mockResponse.statusCode).thenReturn(500);
        when(() => mockResponse.data).thenReturn({'error': 'Server error'});
        when(() => dio.get('http://test.com/cars'))
            .thenAnswer((_) async => mockResponse);
        expect(
          () => api.fetchCars(),
          throwsA(
            isA<FleetApiException>()
                .having((e) => e.message, 'message', 'Failed to fetch cars')
                .having((e) => e.code, 'code', 500),
          ),
        );
      });

      test('throws FleetApiException with null status code for network errors',
          () async {
        when(() => dio.get('http://test.com/cars')).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/cars'),
            message: 'Connection failed',
            // No response = null status code
          ),
        );
        expect(
          () => api.fetchCars(),
          throwsA(
            isA<FleetApiException>()
                .having((e) => e.message, 'message', 'Connection failed')
                .having((e) => e.code, 'code', null),
          ),
        );
      });

      test('rethrows non-Dio exceptions', () async {
        when(() => dio.get('http://test.com/cars'))
            .thenThrow(Exception('Unexpected error'));
        expect(() => api.fetchCars(), throwsA(isA<Exception>()));
      });
    });

    group('fetchCarDetails', () {
      test('makes correct API request', () async {
        final mockResponse = MockResponse();
        when(() => mockResponse.statusCode).thenReturn(200);
        when(() => mockResponse.data).thenReturn(mockCarJson);
        when(() => dio.get('http://test.com/cars/1'))
            .thenAnswer((_) async => mockResponse);
        await api.fetchCarDetails(1);
        verify(() => dio.get('http://test.com/cars/1')).called(1);
      });

      test('returns parsed car data', () async {
        final mockResponse = MockResponse();
        when(() => mockResponse.statusCode).thenReturn(200);
        when(() => mockResponse.data).thenReturn(mockCarJson);
        when(() => dio.get('http://test.com/cars/1'))
            .thenAnswer((_) async => mockResponse);
        final car = await api.fetchCarDetails(1);
        expect(car.id, '1');
        expect(car.name, 'Test Car 1');
      });

      test('throws FleetApiException with status code on non-200 response',
          () async {
        final mockResponse = MockResponse();
        when(() => mockResponse.statusCode).thenReturn(404);
        when(() => mockResponse.data).thenReturn({'error': 'Not found'});
        when(() => dio.get('http://test.com/cars/1'))
            .thenAnswer((_) async => mockResponse);
        expect(
          () => api.fetchCarDetails(1),
          throwsA(
            isA<FleetApiException>()
                .having(
                  (e) => e.message,
                  'message',
                  'Failed to fetch car details',
                )
                .having((e) => e.code, 'code', 404),
          ),
        );
      });

      test('throws FleetApiException with null status code for network errors',
          () async {
        when(() => dio.get('http://test.com/cars/1')).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/cars/1'),
            message: 'Connection timeout',
            // No response = null status code
          ),
        );
        expect(
          () => api.fetchCarDetails(1),
          throwsA(
            isA<FleetApiException>()
                .having((e) => e.message, 'message', 'Connection timeout')
                .having((e) => e.code, 'code', null),
          ),
        );
      });

      test('rethrows non-Dio exceptions', () async {
        when(() => dio.get('http://test.com/cars/1'))
            .thenThrow(Exception('Unexpected error'));
        expect(() => api.fetchCarDetails(1), throwsA(isA<Exception>()));
      });
    });

    group('watchAllCars', () {
      test('calls API periodically', () async {
        final mockResponse = MockResponse();
        when(() => mockResponse.statusCode).thenReturn(200);
        when(() => mockResponse.data).thenReturn(mockCarsJson);
        when(() => dio.get('http://test.com/cars'))
            .thenAnswer((_) async => mockResponse);
        final stream = api.watchAllCars();
        final subscription = stream.listen((_) {});
        await Future<void>.delayed(const Duration(milliseconds: 150));
        await subscription.cancel();
        verify(() => dio.get('http://test.com/cars'))
            .called(greaterThanOrEqualTo(1));
      });
    });

    group('watchCarLocation', () {
      test('calls API with correct car ID', () async {
        final mockResponse = MockResponse();
        when(() => mockResponse.statusCode).thenReturn(200);
        when(() => mockResponse.data).thenReturn(mockCarJson);
        when(() => dio.get('http://test.com/cars/1'))
            .thenAnswer((_) async => mockResponse);
        final stream = api.watchCarLocation(1);
        final subscription = stream.listen((_) {});
        await Future<void>.delayed(const Duration(milliseconds: 150));
        await subscription.cancel();
        verify(() => dio.get('http://test.com/cars/1'))
            .called(greaterThanOrEqualTo(1));
      });
    });

    test('close disposes Dio client', () async {
      when(() => dio.close()).thenAnswer((_) async {});
      await api.close();
      verify(() => dio.close()).called(1);
    });
  });
}
