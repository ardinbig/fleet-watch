import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

/// Trigger initial load of car markers
class MapLoadCars extends HomeEvent {}

/// Trigger update (e.g. periodic)
class MapUpdateCars extends HomeEvent {}
