import 'package:fleet_watch/home/bloc/home_bloc.dart';
import 'package:fleet_watch/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomSearchBar extends StatelessWidget {
  const CustomSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.6,
      child: Material(
        borderRadius: BorderRadius.circular(26),
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
          onChanged: (query) {
            context.read<HomeBloc>().add(MapSearchQueryChanged(query));
          },
        ),
      ),
    );
  }
}
