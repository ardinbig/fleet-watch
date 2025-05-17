//
// ignore_for_file: avoid_setters_without_getters

import 'package:fleet_repository/fleet_repository.dart';
import 'package:fleet_watch/home/bloc/home_bloc.dart';
import 'package:fleet_watch/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.fleetWatchAppBarTitle),
      ),
      body: const HomeView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.read<HomeBloc>().add(MapUpdateCars()),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(MapLoadCars());
  }

  /// Updates the map controller when the map is created
  set mapController(GoogleMapController controller) {
    _mapController = controller;
  }

  void _updateMarkers(List<Car> cars) {
    _markers.clear();
    for (final car in cars) {
      _markers.add(
        Marker(
          markerId: MarkerId(car.id.toString()),
          position: LatLng(car.latitude, car.longitude),
          infoWindow: InfoWindow(title: car.name),
        ),
      );
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeBloc, HomeState>(
      listener: (context, state) {
        if (state is MapViewLoaded) {
          _updateMarkers(state.cars);
          if (_mapController != null && state.cars.isNotEmpty) {
            _mapController!.animateCamera(
              CameraUpdate.newLatLng(
                LatLng(state.cars.first.latitude, state.cars.first.longitude),
              ),
            );
          }
        }
      },
      builder: (context, state) {
        if (state is MapViewLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        return GoogleMap(
          onMapCreated: (controller) => mapController = controller,
          initialCameraPosition: CameraPosition(
            target: state is MapViewLoaded && state.cars.isNotEmpty
                ? LatLng(
                    state.cars.first.latitude,
                    state.cars.first.longitude,
                  )
                : const LatLng(0, 0),
            zoom: 12,
          ),
          markers: _markers,
        );
      },
    );
  }
}
