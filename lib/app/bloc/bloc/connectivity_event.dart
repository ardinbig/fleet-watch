part of 'connectivity_bloc.dart';

abstract class ConnectivityEvent extends Equatable {
  const ConnectivityEvent();

  @override
  List<Object> get props => [];
}

class ConnectivityStatusChanged extends ConnectivityEvent {
  const ConnectivityStatusChanged({required this.results});

  final List<ConnectivityResult> results;

  @override
  List<Object> get props => [results];
}
