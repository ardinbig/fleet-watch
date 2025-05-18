import 'package:fleet_watch/car_detail/bloc/car_detail_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TrackingButton extends StatelessWidget {
  const TrackingButton({required this.isTracking, super.key});

  final bool isTracking;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: () {
          context.read<CarDetailBloc>().add(const ToggleTracking());
        },
        child: Text(
          isTracking ? 'Stop Tracking' : 'Track This Car',
        ),
      ),
    );
  }
}
