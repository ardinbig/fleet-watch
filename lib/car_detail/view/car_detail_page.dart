import 'package:fleet_repository/fleet_repository.dart';
import 'package:fleet_watch/car_detail/car_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CarDetailPage extends StatelessWidget {
  const CarDetailPage({required this.car, required this.repository, super.key});

  final Car car;
  final FleetRepository repository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        return CarDetailBloc(repository: repository)
          ..add(StartTrackingCar(car));
      },
      child: CarDetailView(car: car),
    );
  }
}

class CarDetailView extends StatelessWidget {
  const CarDetailView({required this.car, super.key});

  final Car car;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        final bloc = context.read<CarDetailBloc>();
        if (bloc.state.isTracking) {
          bloc.add(const ToggleTracking());
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(car.name),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              final bloc = context.read<CarDetailBloc>();
              if (bloc.state.isTracking) {
                bloc.add(const ToggleTracking());
              }
              Navigator.of(context).pop();
            },
          ),
        ),
        body: BlocBuilder<CarDetailBloc, CarDetailState>(
          builder: (context, state) {
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Material(
                            color: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(20),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: CarInfoSection(car: state.car),
                            ),
                          ),
                        ),
                        MapSection(car: car),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    height: 80,
                    width: double.infinity,
                    child: TrackingButton(isTracking: state.isTracking),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
