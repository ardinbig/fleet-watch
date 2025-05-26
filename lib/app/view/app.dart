import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:fleet_repository/fleet_repository.dart';
import 'package:fleet_watch/app/bloc/connectivity_bloc.dart';
import 'package:fleet_watch/home/home.dart';
import 'package:fleet_watch/l10n/arb/app_localizations.dart';
import 'package:fleet_watch/l10n/l10n.dart';
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
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ConnectivityBloc>(create: (_) => ConnectivityBloc()),
          BlocProvider<HomeBloc>(
            create: (context) =>
                HomeBloc(repository: context.read<FleetRepository>())
                  ..add(MapLoadCars()),
          ),
        ],
        child: const AppView(),
      ),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({super.key});

  void _showSnackBar({
    required BuildContext context,
    required String title,
    required String message,
    required ContentType contentType,
    Duration? duration,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: AwesomeSnackbarContent(
          title: title,
          message: message,
          contentType: contentType,
        ),
        backgroundColor: Colors.transparent,
        duration: duration ?? const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fleet Watch',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0349A5)),
        useMaterial3: true,
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MultiBlocListener(
        listeners: [
          BlocListener<ConnectivityBloc, ConnectivityState>(
            listener: (context, state) {
              final l10n = context.l10n;
              if (!state.isOnline) {
                _showSnackBar(
                  context: context,
                  title: l10n.offlineTitle,
                  message: l10n.offlineMessage,
                  contentType: ContentType.warning,
                  duration: const Duration(days: 1),
                );
              } else {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              }
            },
          ),
          BlocListener<HomeBloc, HomeState>(
            listener: (context, state) {
              if (state is MapViewError) {
                final l10n = context.l10n;
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                _showSnackBar(
                  context: context,
                  title: l10n.errorTitle,
                  message: state.message,
                  contentType: ContentType.failure,
                );
              }
            },
          ),
        ],
        child: const HomePage(),
      ),
    );
  }
}
