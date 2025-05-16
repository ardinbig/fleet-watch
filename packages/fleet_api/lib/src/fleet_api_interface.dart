import 'package:fleet_api/src/models/models.dart';

/// {@template fleet_api}
///
/// Abstract interface to fetch and stream fleet data.
///
/// {@endtemplate}
abstract class FleetApi {
  /// {@macro fleet_api}
  const FleetApi();

  /// Fetches the current list of cars once.
  Future<List<Car>> fetchCars();

  /// Streams updates to the full list of cars in real time.
  Stream<List<Car>> watchAllCars({
    Duration pollInterval = const Duration(seconds: 5),
  });

  /// Fetches details for a single car by [id].
  Future<Car> fetchCarDetails(int id);

  /// Streams real-time location updates for a single car by [id].
  Stream<Car> watchCarLocation(
    int id, {
    Duration pollInterval = const Duration(seconds: 3),
  });
}
