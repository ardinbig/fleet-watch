part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

/// Trigger initial load of car markers
class MapLoadCars extends HomeEvent {}

/// Trigger update (e.g. periodic)
class MapUpdateCars extends HomeEvent {}

/// Event when map controller is updated
class MapControllerUpdated extends HomeEvent {
  const MapControllerUpdated(this.controller);

  final GoogleMapController controller;

  @override
  List<Object?> get props => [controller];
}

/// Event when search query changes
class MapSearchQueryChanged extends HomeEvent {
  const MapSearchQueryChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

/// Event when filter status changes
class MapFilterStatusChanged extends HomeEvent {
  const MapFilterStatusChanged(this.status);

  final String status;

  @override
  List<Object?> get props => [status];
}
