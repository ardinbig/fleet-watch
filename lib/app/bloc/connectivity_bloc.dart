import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'connectivity_event.dart';
part 'connectivity_state.dart';

class InternetChecker {
  Future<bool> checkInternet() async {
    try {
      final result = await InternetAddress.lookup('8.8.8.8');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } // coverage:ignore-start
    on SocketException catch (_) {
      return false;
    } // coverage:ignore-end
  }
}

class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  ConnectivityBloc({
    Connectivity? connectivity,
    InternetChecker? internetChecker,
  }) : super(const ConnectivityState(isOnline: false)) {
    _connectivity = connectivity ?? Connectivity();
    _internetChecker = internetChecker ?? InternetChecker();

    on<ConnectivityStatusChanged>(_onConnectivityChanged);

    // Initial check
    _checkConnection();

    // Listen for changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (_) => _checkConnection(),
    );
  }

  late final Connectivity _connectivity;
  late final InternetChecker _internetChecker;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  Future<void> _checkConnection() async {
    try {
      final hasConnectivity = await _checkConnectivity();
      if (!hasConnectivity) {
        add(const ConnectivityStatusChanged(isOnline: false));
        return;
      }
      final hasInternet = await _checkInternet();
      add(ConnectivityStatusChanged(isOnline: hasInternet));
    } on Exception catch (_) {
      add(const ConnectivityStatusChanged(isOnline: false));
    }
  }

  Future<bool> _checkConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    if (results.contains(ConnectivityResult.none)) {
      return false;
    }
    return results.contains(ConnectivityResult.wifi) ||
        results.contains(ConnectivityResult.mobile);
  }

  Future<bool> _checkInternet() async {
    return _internetChecker.checkInternet();
  }

  void _onConnectivityChanged(
    ConnectivityStatusChanged event,
    Emitter<ConnectivityState> emit,
  ) {
    emit(ConnectivityState(isOnline: event.isOnline));
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    return super.close();
  }
}
