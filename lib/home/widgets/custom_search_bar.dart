import 'package:fleet_watch/home/bloc/home_bloc.dart';
import 'package:fleet_watch/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomSearchBar extends StatelessWidget {
  const CustomSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Positioned(
      top: 16,
      left: 16,
      right: 80,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(8),
        child: TextField(
          decoration: InputDecoration(
            hintText: l10n.searchHintText,
            prefixIcon: const Icon(Icons.search),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          onChanged: (query) =>
              context.read<HomeBloc>().add(MapSearchQueryChanged(query)),
        ),
      ),
    );
  }
}
