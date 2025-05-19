import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'connectivity_event.dart';
part 'connectivity_state.dart';

class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  ConnectivityBloc() : super(const ConnectivityState(isOnline: true)) {
    on<ConnectivityStatusChanged>(_onConnectivityChanged);

    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      add(ConnectivityStatusChanged(results: results));
    });
  }

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  bool _checkConnectivity(List<ConnectivityResult> results) {
    // Check if either WiFi or mobile data is available
    return results.contains(ConnectivityResult.wifi) ||
        results.contains(ConnectivityResult.mobile);
  }

  void _onConnectivityChanged(
    ConnectivityStatusChanged event,
    Emitter<ConnectivityState> emit,
  ) {
    emit(ConnectivityState(isOnline: _checkConnectivity(event.results)));
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    return super.close();
  }
}
