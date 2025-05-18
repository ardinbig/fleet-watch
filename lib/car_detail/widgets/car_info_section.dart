import 'package:fleet_repository/fleet_repository.dart';
import 'package:flutter/material.dart';

class CarInfoSection extends StatelessWidget {
  const CarInfoSection({required this.car, super.key});

  final Car car;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: const Text('Speed'),
          subtitle: Text('${car.speed} km/h'),
        ),
        ListTile(
          title: const Text('Last Location'),
          subtitle: Text(
            'Lat: ${car.latitude}, Lng: ${car.longitude}',
          ),
        ),
      ],
    );
  }
}
