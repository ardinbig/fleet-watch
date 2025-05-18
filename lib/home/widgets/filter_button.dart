import 'package:fleet_watch/home/bloc/home_bloc.dart';
import 'package:fleet_watch/l10n/arb/app_localizations.dart';
import 'package:fleet_watch/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FilterButton extends StatelessWidget {
  const FilterButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

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
                PopupMenuItem(value: 'All', child: Text(l10n.filterAll)),
                PopupMenuItem(value: 'Moving', child: Text(l10n.filterMoving)),
                PopupMenuItem(value: 'Parked', child: Text(l10n.filterParked)),
              ],
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.filter_list),
                    const SizedBox(width: 4),
                    Text(_getFilterText(currentFilter, l10n)),
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

String _getFilterText(String filter, AppLocalizations l10n) {
  switch (filter) {
    case 'All':
      return l10n.filterAll;
    case 'Moving':
      return l10n.filterMoving;
    case 'Parked':
      return l10n.filterParked;
    default:
      return l10n.filterAll;
  }
}
