import 'package:fleet_api/fleet_api.dart';
import 'package:hive_fleet_api/hive_fleet_api.dart';
import 'package:mock_fleet_api/mock_fleet_api.dart';

/// {@template fleet_repository}
///
/// Implementation of [FleetRepository] that fetches from remote (Dio) and
/// caches to local storage (Hive), falling back to cache when offline.
///
/// {@endtemplate}
class FleetRepository {
  /// {@macro fleet_repository}
  FleetRepository({
    MockFleetApi? remoteApi,
    HiveFleetApi? localApi,
  })  : _remoteApi = remoteApi ?? MockFleetApi(),
        _localApi = localApi ?? HiveFleetApi();

  final MockFleetApi _remoteApi;
  final HiveFleetApi _localApi;

  /// Initializes the repository and local storage.
  Future<void> init() async {
    await _localApi.init();
  }

  /// Fetch cars from remote, cache locally, and return list.
  Future<List<Car>> fetchAndCacheCars() async {
    try {
      final cars = await _remoteApi.fetchCars();
      // Store cars in local storage
      for (final car in cars) {
        await _localApi.box!.put(car.id, car);
      }
      return cars;
    } on Exception catch (_) {
      // On error fallback to cache
      return getCachedCars();
    }
  }

  /// Filter cars by their current status from cache.
  Future<List<Car>> filterCarsByStatus(CarStatus status) async {
    final cars = await getCachedCars();
    return cars.where((car) => car.status == status).toList();
  }

  /// Get cars from local cache directly.
  Future<List<Car>> getCachedCars() async {
    return _localApi.fetchCars();
  }

  /// Watch cars updates using local cache.
  Stream<List<Car>> watchCachedCars({Duration? pollInterval}) {
    return _localApi.watchAllCars(pollInterval: pollInterval);
  }

  /// Fetch details for a single car from remote, update cache, return.
  Future<Car> fetchAndCacheCarDetails(int id) async {
    try {
      final car = await _remoteApi.fetchCarDetails(id);
      // Update in cache
      await _localApi.box!.put(car.id, car);
      return car;
    } on Exception catch (_) {
      return getCachedCarDetails(id);
    }
  }

  /// Get car details from cache.
  Future<Car> getCachedCarDetails(int id) async {
    return _localApi.fetchCarDetails(id);
  }

  /// Watch a single car location from local cache stream.
  Stream<Car> watchCachedCarLocation(int id, {Duration? pollInterval}) {
    return _localApi.watchCarLocation(id, pollInterval: pollInterval);
  }

  /// Disposes any resources managed by the repository.
  void dispose() {
    _remoteApi.close();
    _localApi.close();
  }
}
