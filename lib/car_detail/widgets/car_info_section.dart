import 'package:fleet_repository/fleet_repository.dart';
import 'package:fleet_watch/l10n/arb/app_localizations.dart';
import 'package:fleet_watch/l10n/l10n.dart';
import 'package:flutter/material.dart';

class CarInfoSection extends StatelessWidget {
  const CarInfoSection({required this.car, super.key});

  final Car car;

  String _getLocalizedStatus(CarStatus status, AppLocalizations l10n) {
    switch (status) {
      case CarStatus.moving:
        return l10n.carStatusMoving;
      case CarStatus.parked:
        return l10n.carStatusParked;
      case CarStatus.unknown:
        return l10n.carStatusUnknown;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return Column(
      children: [
        ListTile(
          title: Text('Speed', style: textTheme.headlineMedium),
          subtitle: Text('${car.speed} km/h', style: textTheme.bodyLarge),
          trailing: Column(
            children: [
              Text(
                _getLocalizedStatus(car.status, l10n).toUpperCase(),
                style: textTheme.labelLarge,
              ),
              const Icon(Icons.directions_car, size: 34),
            ],
          ),
        ),
        ListTile(
          title: Text(l10n.carLastLocation, style: textTheme.headlineMedium),
          subtitle: Text(
            'Lat: ${car.latitude}, Lng: ${car.longitude}',
            style: textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}
