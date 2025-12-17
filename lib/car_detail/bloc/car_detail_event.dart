part of 'car_detail_bloc.dart';

/// Base class for all car detail events
sealed class CarDetailEvent extends Equatable {
  const CarDetailEvent();

  @override
  List<Object> get props => [];
}

/// Event to start tracking a specific car's location
class StartTrackingCar extends CarDetailEvent {
  const StartTrackingCar(this.car);

  /// The car to track
  final Car car;

  @override
  List<Object> get props => [car];
}

/// Event to toggle tracking on/off for the current car
class ToggleTracking extends CarDetailEvent {
  const ToggleTracking();
}

/// Event emitted when a car's location is updated
///
/// This event is not meant to be dispatched directly by the UI
class UpdateCarLocation extends CarDetailEvent {
  const UpdateCarLocation(this.car);

  /// The car with updated location
  final Car car;

  @override
  List<Object> get props => [car];
}

/// Event when map controller is updated
class MapControllerUpdated extends CarDetailEvent {
  const MapControllerUpdated(this.controller);

  final GoogleMapController controller;

  @override
  List<Object> get props => [controller];
}
