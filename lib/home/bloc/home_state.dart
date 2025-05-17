import 'package:equatable/equatable.dart';
import 'package:fleet_repository/fleet_repository.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class MapViewInitial extends HomeState {}

class MapViewLoading extends HomeState {}

class MapViewLoaded extends HomeState {
  const MapViewLoaded(this.cars);

  final List<Car> cars;

  @override
  List<Object?> get props => [cars];
}

class MapViewError extends HomeState {
  const MapViewError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
