import 'package:fleet_watch/home/bloc/home_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FilterButton extends StatelessWidget {
  const FilterButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 16,
      right: 16,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(8),
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            final currentFilter =
                state is MapViewLoaded ? state.filterStatus : 'All';
            return PopupMenuButton<String>(
              initialValue: currentFilter,
              onSelected: (value) =>
                  context.read<HomeBloc>().add(MapFilterStatusChanged(value)),
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'All', child: Text('All')),
                const PopupMenuItem(value: 'Moving', child: Text('Moving')),
                const PopupMenuItem(value: 'Parked', child: Text('Parked')),
              ],
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.filter_list),
                    const SizedBox(width: 4),
                    Text(currentFilter),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
