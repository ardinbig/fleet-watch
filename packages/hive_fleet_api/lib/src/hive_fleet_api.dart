import 'dart:async';
import 'dart:convert';

import 'package:fleet_api/fleet_api.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:hive_fleet_api/src/hive/hive_adapters.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

/// {@template hive_fleet_api}
///
/// Concrete [FleetApi] implementation using Hive for storage
/// and periodic polling.
///
/// {@endtemplate}
class HiveFleetApi implements FleetApi {
  /// {@macro hive_fleet_api}
  HiveFleetApi({
    this.pollInterval = const Duration(seconds: 3),
    HiveInterface? hive,
    FlutterSecureStorage? secureStorage,
  })  : _hive = hive ?? Hive,
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Polling interval for fetching data from the box.
  /// This is used to update the stream of cars.
  final Duration pollInterval;

  final HiveInterface _hive;
  final FlutterSecureStorage _secureStorage;

  static const _boxName = 'cars';
  static const _encryptionKey = 'hive_encryption_key';

  Box<Car>? _box;

  /// Accessor for testing
  @visibleForTesting
  Box<Car>? get box => _box;

  // Internal subject for streaming updates
  final _allCarsSubject = BehaviorSubject<List<Car>>();
  final Map<int, BehaviorSubject<Car>> _carSubjects = {};
  Timer? _refreshTimer;

  /// Initialize the HiveFleetApi.
  ///
  /// This method must be called before using any other methods.
  Future<void> init() async {
    try {
      await _hive.initFlutter();
      await _registerAdapters();

      final encryptionKey = await _getEncryptionKey();
      final encryptionCipher = HiveAesCipher(encryptionKey);

      _box = await _hive.openBox<Car>(
        _boxName,
        encryptionCipher: encryptionCipher,
      );
    } catch (e) {
      throw FleetApiException('Failed initializing Hive: $e');
    }
  }

  /// Saves a car to the box
  ///
  /// This is used by the repository to cache cars without directly
  /// accessing private members.
  Future<void> saveCar(Car car) async {
    _assertInitialized();
    try {
      await _box!.put(car.id, car);
    } catch (e) {
      throw FleetApiException('Failed to save car: $e');
    }
  }

  Future<void> _registerAdapters() async {
    // Register adapters only once
    if (!_hive.isAdapterRegistered(0)) {
      _hive
        ..registerAdapter(CarAdapter())
        ..registerAdapter(CarStatusAdapter());
    }
  }

  Future<List<int>> _getEncryptionKey() async {
    // Check if key exists in secure storage
    final existingKey = await _secureStorage.read(key: _encryptionKey);
    if (existingKey != null) {
      return base64Decode(existingKey);
    }

    // Generate a new key if none exists
    final newKey = _hive.generateSecureKey();
    final encodedKey = base64Encode(newKey);
    await _secureStorage.write(key: _encryptionKey, value: encodedKey);
    return newKey;
  }

  void _assertInitialized() {
    if (_box == null) {
      throw FleetApiException('HiveFleetApi not initialized');
    }
  }

  void _refreshCars() {
    try {
      final cars = _box!.values.toList();
      _allCarsSubject.add(cars);

      // Update individual car subjects
      for (final carSubject in _carSubjects.entries) {
        final car = _box!.get(carSubject.key);
        if (car != null) {
          carSubject.value.add(car);
        }
      }
    } on Exception catch (e) {
      _allCarsSubject.addError(FleetApiException('Error fetching cars: $e'));
    }
  }

  void _refreshCar(int id) {
    try {
      final car = _box!.get(id);
      if (car == null) {
        _carSubjects[id]?.addError(FleetApiException('Car $id not found'));
        return;
      }
      _carSubjects[id]?.add(car);
    } on Exception catch (e) {
      _carSubjects[id]?.addError(FleetApiException('Error fetching car: $e'));
    }
  }

  @override
  Future<List<Car>> fetchCars() async {
    _assertInitialized();
    try {
      return _box!.values.toList();
    } catch (e) {
      throw FleetApiException('Failed reading cars from local storage: $e');
    }
  }

  @override
  Stream<List<Car>> watchAllCars({Duration? pollInterval}) {
    _assertInitialized();

    // Initial emission
    _refreshCars();

    // Start periodic updates
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(
      pollInterval ?? this.pollInterval,
      (_) => _refreshCars(),
    );

    return _allCarsSubject.stream;
  }

  @override
  Future<Car> fetchCarDetails(int id) async {
    _assertInitialized();

    try {
      final car = _box!.get(id);
      if (car == null) {
        throw FleetApiException('Car $id not found');
      }
      return car;
    } catch (e) {
      if (e is FleetApiException) {
        rethrow;
      }
      throw FleetApiException('Error fetching car details: $e');
    }
  }

  @override
  Stream<Car> watchCarLocation(int id, {Duration? pollInterval}) {
    _assertInitialized();

    // Create or get subject for this car
    _carSubjects[id] ??= BehaviorSubject<Car>();

    // Initial emission
    _refreshCar(id);

    return _carSubjects[id]!.stream;
  }

  @override
  Future<void> close() async {
    _refreshTimer?.cancel();
    _refreshTimer = null;

    // Close all subjects
    await _allCarsSubject.close();
    for (final subject in _carSubjects.values) {
      await subject.close();
    }
    _carSubjects.clear();

    // Close Hive box
    await _box?.close();
    _box = null;
  }
}
