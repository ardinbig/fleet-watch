import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fleet_repository/fleet_repository.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

part 'car_detail_event.dart';
part 'car_detail_state.dart';

class CarDetailBloc extends Bloc<CarDetailEvent, CarDetailState> {
  CarDetailBloc({required FleetRepository repository})
    : _repository = repository,
      super(CarDetailState.initial()) {
    on<StartTrackingCar>(_onStartTracking);
    on<ToggleTracking>(_onToggleTracking);
    on<UpdateCarLocation>(_onUpdateCarLocation);
    on<MapControllerUpdated>(_onMapControllerUpdated);
  }

  final FleetRepository _repository;
  Timer? _timer;

  void _onStartTracking(StartTrackingCar event, Emitter<CarDetailState> emit) {
    emit(state.copyWith(car: event.car));
  }

  Future<void> _onToggleTracking(
    ToggleTracking event,
    Emitter<CarDetailState> emit,
  ) async {
    final isTracking = !state.isTracking;
    emit(state.copyWith(isTracking: isTracking));
    _timer?.cancel();

    if (isTracking) {
      _timer = Timer.periodic(const Duration(seconds: 5), (_) async {
        await _fetchCarUpdate();
      });
    }
  }

  Future<void> _fetchCarUpdate() async {
    await _repository
        .fetchAndCacheCarDetails(
          int.parse(state.car.id),
        )
        .then((updatedCar) => add(UpdateCarLocation(updatedCar)));
  }

  Future<void> _onUpdateCarLocation(
    UpdateCarLocation event,
    Emitter<CarDetailState> emit,
  ) async {
    emit(state.copyWith(car: event.car));

    // Update camera position when car location changes
    await state.mapController?.animateCamera(
      CameraUpdate.newLatLng(LatLng(event.car.latitude, event.car.longitude)),
    );
  }

  void _onMapControllerUpdated(
    MapControllerUpdated event,
    Emitter<CarDetailState> emit,
  ) {
    emit(state.copyWith(mapController: event.controller));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    state.mapController?.dispose();
    return super.close();
  }
}
