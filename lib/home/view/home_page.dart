import 'package:fleet_watch/home/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is MapViewLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return Stack(
              children: [
                const HomeView(),
                Positioned(
                  top: 18,
                  left: 18,
                  right: 18,
                  child: SizedBox(
                    height: 60,
                    child: Material(
                      elevation: 3,
                      shadowColor: Theme.of(context).colorScheme.shadow,
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(30),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomSearchBar(),
                            FilterButton(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
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
