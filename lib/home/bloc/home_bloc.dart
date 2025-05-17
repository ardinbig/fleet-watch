import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fleet_repository/fleet_repository.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({required this.repository}) : super(MapViewInitial()) {
    on<MapLoadCars>(_onLoadCars);
    on<MapUpdateCars>(_onUpdateCars);
  }

  final FleetRepository repository;
  Timer? _timer;

  Future<void> _onLoadCars(MapLoadCars event, Emitter<HomeState> emit) async {
    emit(MapViewLoading());
    try {
      await repository.init();
      final cars = await repository.fetchAndCacheCars();
      emit(MapViewLoaded(cars));

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
      try {
        final cars = await repository.getCachedCars();
        emit(MapViewLoaded(cars));
      } on Exception catch (e) {
        emit(MapViewError(e.toString()));
      }
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
