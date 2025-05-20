part of 'connectivity_bloc.dart';

sealed class ConnectivityEvent extends Equatable {
  const ConnectivityEvent();

  @override
  List<Object> get props => [];
}

class ConnectivityStatusChanged extends ConnectivityEvent {
  const ConnectivityStatusChanged({required this.isOnline});

  final bool isOnline;

  @override
  List<Object> get props => [isOnline];
}
