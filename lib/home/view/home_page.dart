import 'package:fleet_watch/home/home.dart';
import 'package:fleet_watch/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.fleetWatchAppBarTitle),
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is MapViewLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return const Stack(
            children: [
              HomeView(),
              CustomSearchBar(),
              FilterButton(),
            ],
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is MapViewLoading) {
            return const SizedBox.shrink();
          }
          return FloatingActionButton(
            onPressed: () => context.read<HomeBloc>().add(MapUpdateCars()),
            child: const Icon(Icons.refresh),
          );
        },
      ),
    );
  }
}
