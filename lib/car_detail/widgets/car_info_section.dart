import 'package:fleet_repository/fleet_repository.dart';
import 'package:flutter/material.dart';

class CarInfoSection extends StatelessWidget {
  const CarInfoSection({required this.car, super.key});

  final Car car;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        ListTile(
          title: Text('Speed', style: textTheme.headlineMedium),
          subtitle: Text('${car.speed} km/h', style: textTheme.bodyLarge),
        ),
        ListTile(
          title: Text('Last Location', style: textTheme.headlineMedium),
          subtitle: Text(
            'Lat: ${car.latitude}, Lng: ${car.longitude}',
            style: textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}
