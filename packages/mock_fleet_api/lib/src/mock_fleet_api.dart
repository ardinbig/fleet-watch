//
// ignore_for_file: inference_failure_on_function_invocation

import 'package:dio/dio.dart';
import 'package:fleet_api/fleet_api.dart';
import 'package:mock_fleet_api/src/dio/app_interceptors.dart';

/// {@template mock_fleet_api}
///
/// Concrete [FleetApi] implementation using Dio to fetch from remote endpoint.
///
/// {@endtemplate}
class MockFleetApi implements FleetApi {
  /// {@macro mock_fleet_api}
  MockFleetApi({
    Dio? dio,
    String baseUrl = 'https://68263c13397e48c913157416.mockapi.io',
    this.pollInterval = const Duration(seconds: 5),
  }) : _dio = dio ?? Dio(BaseOptions(baseUrl: baseUrl)),
       _baseUrl = baseUrl {
    _dio.options.connectTimeout = const Duration(seconds: 15);
    _dio.options.receiveTimeout = const Duration(seconds: 15);
    _dio.interceptors.add(AppInterceptors());
  }

  final Dio _dio;
  final String _baseUrl;

  /// The interval at which to poll for updates.
  /// Defaults to 5 seconds.
  /// This is used for the [watchAllCars] and [watchCarLocation] methods.
  /// If not provided, the default value will be used.
  final Duration pollInterval;

  @override
  Future<List<Car>> fetchCars() async {
    try {
      final response = await _dio.get('$_baseUrl/cars');
      if (response.statusCode == 200) {
        final data = response.data as List;
        return data.map((json) => Car.fromJson(json as JsonMap)).toList();
      } else {
        throw FleetApiException('Failed to fetch cars', response.statusCode);
      }
    } catch (e) {
      if (e is DioException) {
        throw FleetApiException(e.message!, e.response?.statusCode);
      }
      rethrow;
    }
  }

  @override
  Stream<List<Car>> watchAllCars({Duration? pollInterval}) {
    final interval = pollInterval ?? this.pollInterval;
    return Stream.periodic(
      interval,
      (_) => fetchCars(),
    ).asyncMap((future) => future);
  }

  @override
  Future<Car> fetchCarDetails(int id) async {
    try {
      final response = await _dio.get('$_baseUrl/cars/$id');
      if (response.statusCode == 200) {
        return Car.fromJson(response.data as JsonMap);
      } else {
        throw FleetApiException(
          'Failed to fetch car details',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is DioException) {
        throw FleetApiException(e.message!, e.response?.statusCode);
      }
      rethrow;
    }
  }

  @override
  Stream<Car> watchCarLocation(int id, {Duration? pollInterval}) {
    final interval = pollInterval ?? this.pollInterval;
    return Stream.periodic(
      interval,
      (_) => fetchCarDetails(id),
    ).asyncMap((future) => future);
  }

  @override
  Future<void> close() async {
    _dio.close();
  }
}
