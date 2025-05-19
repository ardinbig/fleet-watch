import 'package:fleet_repository/fleet_repository.dart';
import 'package:fleet_watch/home/home.dart';
import 'package:fleet_watch/l10n/arb/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class App extends StatelessWidget {
  const App({required this.createFleetRepository, super.key});

  final FleetRepository Function() createFleetRepository;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<FleetRepository>(
      create: (context) => createFleetRepository(),
      dispose: (repository) => repository.dispose(),
      child: BlocProvider<HomeBloc>(
        create: (context) => HomeBloc(
          repository: context.read<FleetRepository>(),
        )..add(MapLoadCars()),
        child: const AppView(),
      ),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fleet Watch',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0349A5),
        ),
        useMaterial3: true,
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const HomePage(),
    );
  }
}
