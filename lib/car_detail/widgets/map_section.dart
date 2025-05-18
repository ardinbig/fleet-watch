import 'package:fleet_repository/fleet_repository.dart';
import 'package:fleet_watch/car_detail/bloc/car_detail_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapSection extends StatelessWidget {
  const MapSection({required this.car, super.key});

  final Car car;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      margin: const EdgeInsets.all(12),
      child: BlocBuilder<CarDetailBloc, CarDetailState>(
        builder: (context, state) {
          final marker = Marker(
            markerId: MarkerId(car.id),
            position: LatLng(car.latitude, car.longitude),
            infoWindow: InfoWindow(title: car.name),
          );

          return GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(car.latitude, car.longitude),
              zoom: 14,
            ),
            onMapCreated: (controller) {
              context
                  .read<CarDetailBloc>()
                  .add(MapControllerUpdated(controller));
            },
            markers: {marker},
            zoomControlsEnabled: false,
          );
        },
      ),
    );
  }
}
