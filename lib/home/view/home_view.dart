import 'package:fleet_repository/fleet_repository.dart';
import 'package:fleet_watch/home/bloc/home_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      buildWhen: (previous, current) {
        return previous != current;
      },
      builder: (context, state) {
        return GoogleMap(
          onMapCreated: (controller) =>
              context.read<HomeBloc>().add(MapControllerUpdated(controller)),
          initialCameraPosition: CameraPosition(
            target: state is MapViewLoaded && state.filteredCars.isNotEmpty
                ? LatLng(
                    state.filteredCars.first.latitude,
                    state.filteredCars.first.longitude,
                  )
                : const LatLng(0, 0),
            zoom: 12,
          ),
          markers:
              state is MapViewLoaded ? _createMarkers(state.filteredCars) : {},
        );
      },
    );
  }

  Set<Marker> _createMarkers(List<Car> cars) {
    return cars
        .map(
          (car) => Marker(
            markerId: MarkerId(car.id),
            position: LatLng(car.latitude, car.longitude),
            infoWindow: InfoWindow(
              title: car.name,
              snippet: car.status.toString().toUpperCase().split('.').last,
            ),
          ),
        )
        .toSet();
  }
}
