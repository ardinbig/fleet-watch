part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

/// Initial state before map is loaded
class MapViewInitial extends HomeState {}

/// Loading state while fetching data
class MapViewLoading extends HomeState {}

/// Loaded state with cars data and filter/search state
class MapViewLoaded extends HomeState {
  const MapViewLoaded({
    required this.cars,
    required this.filteredCars,
    this.controller,
    this.searchQuery = '',
    this.filterStatus = 'All',
  });

  final List<Car> cars;
  final List<Car> filteredCars;
  final GoogleMapController? controller;
  final String searchQuery;
  final String filterStatus;

  @override
  List<Object?> get props => [
    cars,
    filteredCars,
    controller,
    searchQuery,
    filterStatus,
  ];

  /// Creates a copy of the state with updated fields
  MapViewLoaded copyWith({
    List<Car>? cars,
    List<Car>? filteredCars,
    GoogleMapController? controller,
    String? searchQuery,
    String? filterStatus,
  }) {
    return MapViewLoaded(
      cars: cars ?? this.cars,
      filteredCars: filteredCars ?? this.filteredCars,
      controller: controller ?? this.controller,
      searchQuery: searchQuery ?? this.searchQuery,
      filterStatus: filterStatus ?? this.filterStatus,
    );
  }
}

/// Error state with error message
class MapViewError extends HomeState {
  const MapViewError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
