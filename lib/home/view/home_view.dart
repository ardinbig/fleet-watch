import 'package:fleet_repository/fleet_repository.dart';
import 'package:fleet_watch/car_detail/view/car_detail_page.dart';
import 'package:fleet_watch/home/bloc/home_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  BitmapDescriptor? _carMarker;

  @override
  void initState() {
    super.initState();
    _loadMarkerIcon();
  }

  Future<void> _loadMarkerIcon() async {
    _carMarker = await BitmapDescriptor.asset(
      ImageConfiguration.empty,
      'assets/car_marker.png',
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) {
        return GoogleMap(
          onMapCreated: (controller) {
            context.read<HomeBloc>().add(MapControllerUpdated(controller));
          },
          initialCameraPosition: CameraPosition(
            target: state is MapViewLoaded && state.filteredCars.isNotEmpty
                ? LatLng(
                    state.filteredCars.first.latitude,
                    state.filteredCars.first.longitude,
                  )
                : const LatLng(0, 0),
            zoom: 14,
          ),
          markers: state is MapViewLoaded
              ? _createMarkers(context, state.filteredCars)
              : {},
        );
      },
    );
  }

  Set<Marker> _createMarkers(BuildContext context, List<Car> cars) {
    return cars.map(
      (car) {
        return Marker(
          markerId: MarkerId(car.id),
          icon: _carMarker ?? BitmapDescriptor.defaultMarker,
          position: LatLng(car.latitude, car.longitude),
          infoWindow: InfoWindow(
            title: car.name,
            snippet: car.status.toString().toUpperCase().split('.').last,
          ),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<dynamic>(
                builder: (context) {
                  return CarDetailPage(
                    car: car,
                    repository: context.read<FleetRepository>(),
                  );
                },
              ),
            );
          },
        );
      },
    ).toSet();
  }
}
