import 'package:fleet_watch/l10n/l10n.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.fleetWatchAppBarTitle),
      ),
      body: Center(
        child: Text(l10n.fleetWatchAppBarTitle),
      ),
    );
  }
}
