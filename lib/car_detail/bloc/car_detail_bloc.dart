import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fleet_repository/fleet_repository.dart';

part 'car_detail_event.dart';
part 'car_detail_state.dart';

class CarDetailBloc extends Bloc<CarDetailEvent, CarDetailState> {
  CarDetailBloc({required this.repository}) : super(CarDetailState.initial()) {
    on<StartTrackingCar>(_onStartTracking);
    on<ToggleTracking>(_onToggleTracking);
    on<_UpdateCarLocation>(_onUpdateCarLocation);
  }

  final FleetRepository repository;
  Timer? _timer;

  void _onStartTracking(StartTrackingCar event, Emitter<CarDetailState> emit) {
    emit(state.copyWith(car: event.car));
  }

  void _onToggleTracking(ToggleTracking event, Emitter<CarDetailState> emit) {
    final isTracking = !state.isTracking;
    emit(state.copyWith(isTracking: isTracking));
    _timer?.cancel();

    if (isTracking) {
      _timer = Timer.periodic(const Duration(seconds: 5), (_) async {
        final updatedCar = await repository.fetchAndCacheCarDetails(
          int.parse(state.car.id),
        );
        add(_UpdateCarLocation(updatedCar));
      });
    }
  }

  void _onUpdateCarLocation(
    _UpdateCarLocation event,
    Emitter<CarDetailState> emit,
  ) {
    emit(state.copyWith(car: event.car));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
