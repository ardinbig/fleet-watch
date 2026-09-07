part of 'connectivity_bloc.dart';

sealed class ConnectivityEvent extends Equatable {
  const new();
}

class ConnectivityStatusChanged extends ConnectivityEvent {
  const new({required this.isOnline});

  final bool isOnline;

  @override
  List<Object> get props => [isOnline];
}
