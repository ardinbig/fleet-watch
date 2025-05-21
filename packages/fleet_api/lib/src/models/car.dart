import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'car.g.dart';

///{@template car_item}
///
/// A class representing a car in the fleet.
///
/// {@endtemplate}
@immutable
@JsonSerializable()
class Car extends Equatable {
  /// {@macro car_item}
  const Car({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.speed,
    required this.status,
  });

  /// The unique identifier of the car.
  final String id;

  /// The name of the car.
  final String name;

  /// The latitude of the car's location.
  final double latitude;

  /// The longitude of the car's location.
  final double longitude;

  /// The speed of the car in km/h.
  final double speed;

  /// The status of the car, which can be moving, parked, or unknown.
  final CarStatus status;

  /// Creates a new [Car] instance from a JSON map.
  static Car fromJson(JsonMap json) => _$CarFromJson(json);

  /// Converts the [Car] instance to a JSON map.
  JsonMap toJson() => _$CarToJson(this);

  @override
  List<Object?> get props => [id, name, latitude, longitude, speed, status];
}

/// Enum representing possible car statuses.
enum CarStatus {
  /// The car is moving.
  moving,

  /// The car is packed.
  parked,

  /// The car is unknown.
  unknown,
}

/// The type definition for a JSON-serializable [Map].
typedef JsonMap = Map<String, dynamic>;
