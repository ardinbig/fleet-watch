import 'package:fleet_watch/car_detail/bloc/car_detail_bloc.dart';
import 'package:fleet_watch/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TrackingButton extends StatelessWidget {
  const TrackingButton({required this.isTracking, super.key});

  final bool isTracking;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: () {
          context.read<CarDetailBloc>().add(const ToggleTracking());
        },
        child: Text(
          isTracking ? l10n.stopTracking : l10n.startTracking,
        ),
      ),
    );
  }
}
