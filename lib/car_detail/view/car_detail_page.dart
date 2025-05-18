import 'package:fleet_repository/fleet_repository.dart';
import 'package:fleet_watch/car_detail/bloc/car_detail_bloc.dart';
import 'package:fleet_watch/car_detail/widgets/widgets.dart';
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
    return Scaffold(
      appBar: AppBar(title: Text(car.name)),
      body: BlocBuilder<CarDetailBloc, CarDetailState>(
        builder: (context, state) {
          return Column(
            children: [
              CarInfoSection(car: state.car),
              MapSection(car: car),
              TrackingButton(isTracking: state.isTracking),
            ],
          );
        },
      ),
    );
  }
}
