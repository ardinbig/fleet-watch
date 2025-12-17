part of 'car_detail_bloc.dart';

class CarDetailState extends Equatable {
  const CarDetailState({
    required this.car,
    required this.isTracking,
    this.mapController,
  });

  factory CarDetailState.initial() {
    return const CarDetailState(
      car: Car(
        id: '0',
        name: '',
        latitude: 0,
        longitude: 0,
        speed: 0,
        status: CarStatus.parked,
      ),
      isTracking: false,
    );
  }

  final Car car;
  final bool isTracking;
  final GoogleMapController? mapController;

  CarDetailState copyWith({
    Car? car,
    bool? isTracking,
    GoogleMapController? mapController,
  }) {
    return CarDetailState(
      car: car ?? this.car,
      isTracking: isTracking ?? this.isTracking,
      mapController: mapController ?? this.mapController,
    );
  }

  @override
  List<Object> get props => [car, isTracking, mapController ?? ''];
}
