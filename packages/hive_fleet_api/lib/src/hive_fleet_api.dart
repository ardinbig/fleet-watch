import 'dart:async';

import 'package:fleet_api/fleet_api.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:hive_fleet_api/src/hive/hive_adapters.dart';
import 'package:rxdart/rxdart.dart';

/// {@template hive_fleet_api}
///
/// Concrete [FleetApi] implementation using Hive for storage
/// and periodic polling.
///
/// {@endtemplate}
class HiveFleetApi implements FleetApi {
  /// {@macro hive_fleet_api}
  HiveFleetApi({this.pollInterval = const Duration(seconds: 3)});

  /// Polling interval for fetching data from the box.
  /// This is used to update the stream of cars.
  final Duration pollInterval;

  static const _boxName = 'cars';
  static const _encryptionKey = 'HiveEncryptionKey';
  static const _secureStorage = FlutterSecureStorage();
  late Box<Car>? _box;

  // Internal subject for streaming updates
  BehaviorSubject<List<Car>>? _allCarsSubject;

  /// Gets the Hive box instance for car storage.
  /// Returns null if the box hasn't been initialized.
  Box<Car>? get box => _box;

  /// Initializes Hive and opens the box. Call before use.
  Future<void> init() async {
    await Hive.initFlutter();
    try {
      if (!Hive.isAdapterRegistered(0)) {
        Hive
          ..registerAdapter(CarAdapter())
          ..registerAdapter(CarStatusAdapter());
      }

      final encryptionKey = await _getEncryptionKey();

      _box = await Hive.openBox<Car>(
        _boxName,
        encryptionCipher: HiveAesCipher(encryptionKey),
      );
      // Seed subject
      _allCarsSubject = BehaviorSubject<List<Car>>.seeded(_getAllCarsFromBox());
      // Start polling
      Timer.periodic(pollInterval, (_) {
        _allCarsSubject?.add(_getAllCarsFromBox());
      });
    } catch (e) {
      throw FleetApiException('Failed initializing Hive: $e');
    }
  }

  Future<List<int>> _getEncryptionKey() async {
    // Check if key exists in secure storage
    final existingKey = await _secureStorage.read(key: _encryptionKey);
    if (existingKey != null) {
      return existingKey.codeUnits;
    } else {
      // Generate new 256-bit key
      final newKey = Hive.generateSecureKey();
      await _secureStorage.write(
        key: _encryptionKey,
        value: String.fromCharCodes(newKey),
      );
      return newKey;
    }
  }

  List<Car> _getAllCarsFromBox() {
    try {
      return _box!.values.map((e) => e).toList();
    } on Exception catch (e) {
      throw FleetApiException('Failed reading cars from local storage: $e');
    }
  }

  @override
  Future<List<Car>> fetchCars() async {
    if (_box == null) {
      throw FleetApiException('HiveFleetApi not initialized');
    }
    return _getAllCarsFromBox();
  }

  @override
  Stream<List<Car>> watchAllCars({Duration? pollInterval}) {
    if (_allCarsSubject == null) {
      throw FleetApiException('HiveFleetApi not initialized');
    }
    return _allCarsSubject!.stream;
  }

  @override
  Future<Car> fetchCarDetails(int id) async {
    if (_box == null) {
      throw FleetApiException('HiveFleetApi not initialized');
    }

    try {
      final model = _box!.get(id);
      if (model == null) throw FleetApiException('Car with id $id not found');
      return model;
    } on Exception catch (e) {
      throw FleetApiException('Error fetching car details: $e');
    }
  }

  @override
  Stream<Car> watchCarLocation(int id, {Duration? pollInterval}) {
    // Polling by mapping the all-cars stream to only the requested car
    return watchAllCars().map((cars) {
      final match = cars.firstWhere(
        (c) => c.id == id,
        orElse: () => throw FleetApiException('Car $id not found'),
      );
      return match;
    });
  }

  @override
  Future<void> close() async {
    await _allCarsSubject?.close();
    await _box?.close();
  }
}
