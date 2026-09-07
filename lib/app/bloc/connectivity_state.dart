part of 'connectivity_bloc.dart';

class ConnectivityState extends Equatable {
  const new({required this.isOnline});

  final bool isOnline;

  @override
  List<Object> get props => [isOnline];
}
