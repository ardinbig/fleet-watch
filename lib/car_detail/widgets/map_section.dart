import 'package:fleet_repository/fleet_repository.dart';
import 'package:fleet_watch/car_detail/bloc/car_detail_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapSection extends StatefulWidget {
  const MapSection({required this.car, super.key});

  final Car car;

  @override
  State<MapSection> createState() => _MapSectionState();
}

class _MapSectionState extends State<MapSection> {
  BitmapDescriptor? _carMarker;

  @override
  void initState() {
    super.initState();
    _loadMarkerIcon();
  }

  Future<void> _loadMarkerIcon() async {
    _carMarker = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/car_marker.png',
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      margin: const EdgeInsets.all(12),
      child: BlocBuilder<CarDetailBloc, CarDetailState>(
        builder: (context, state) {
          final marker = Marker(
            markerId: MarkerId(widget.car.id),
            position: LatLng(widget.car.latitude, widget.car.longitude),
            icon: _carMarker ?? BitmapDescriptor.defaultMarker,
            infoWindow: InfoWindow(title: widget.car.name),
          );

          return GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(widget.car.latitude, widget.car.longitude),
              zoom: 16,
            ),
            onMapCreated: (controller) {
              context.read<CarDetailBloc>().add(
                MapControllerUpdated(controller),
              );
            },
            markers: {marker},
            zoomControlsEnabled: false,
          );
        },
      ),
    );
  }
}
