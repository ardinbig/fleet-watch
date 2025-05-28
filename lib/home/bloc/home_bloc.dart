import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:fleet_repository/fleet_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({required FleetRepository repository})
    : _repository = repository,
      super(MapViewInitial()) {
    on<MapLoadCars>(_onLoadCars);
    on<MapUpdateCars>(_onUpdateCars);
    on<MapControllerUpdated>(_onMapControllerUpdated);
    on<MapSearchQueryChanged>(_onSearchQueryChanged);
    on<MapFilterStatusChanged>(_onFilterStatusChanged);
  }

  final FleetRepository _repository;
  Timer? _timer;

  Future<void> _onLoadCars(MapLoadCars event, Emitter<HomeState> emit) async {
    emit(MapViewLoading());
    try {
      final cars = await _repository.fetchAndCacheCars();
      emit(MapViewLoaded(cars: cars, filteredCars: cars));

      // Start periodic updates
      _timer = Timer.periodic(const Duration(seconds: 5), (_) {
        add(MapUpdateCars());
      });
    } on Exception catch (e) {
      emit(MapViewError(e.toString()));
    }
  }

  Future<void> _onUpdateCars(
    MapUpdateCars event,
    Emitter<HomeState> emit,
  ) async {
    if (state is MapViewLoaded) {
      final currentState = state as MapViewLoaded;
      try {
        final cars = await _repository.getCachedCars();
        emit(_applyFilters(currentState.copyWith(cars: cars)));
      } on Exception catch (e) {
        emit(MapViewError(e.toString()));
      }
    }
  }

  void _onMapControllerUpdated(
    MapControllerUpdated event,
    Emitter<HomeState> emit,
  ) {
    if (state is MapViewLoaded) {
      final currentState = state as MapViewLoaded;
      emit(currentState.copyWith(controller: event.controller));
    }
  }

  void _onSearchQueryChanged(
    MapSearchQueryChanged event,
    Emitter<HomeState> emit,
  ) {
    if (state is MapViewLoaded) {
      final currentState = state as MapViewLoaded;
      emit(_applyFilters(currentState.copyWith(searchQuery: event.query)));
    }
  }

  void _onFilterStatusChanged(
    MapFilterStatusChanged event,
    Emitter<HomeState> emit,
  ) {
    if (state is MapViewLoaded) {
      final currentState = state as MapViewLoaded;
      emit(_applyFilters(currentState.copyWith(filterStatus: event.status)));
    }
  }

  MapViewLoaded _applyFilters(MapViewLoaded state) {
    final query = state.searchQuery.toLowerCase();
    final filteredCars = state.cars.where((car) {
      final matchesSearch =
          car.name.toLowerCase().contains(query) || car.id.contains(query);
      final matchesStatus =
          state.filterStatus == 'All' ||
          car.status.toString().split('.').last.toLowerCase() ==
              state.filterStatus.toLowerCase();
      return matchesSearch && matchesStatus;
    }).toList();

    return state.copyWith(filteredCars: filteredCars);
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
