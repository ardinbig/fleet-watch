import 'package:fleet_repository/fleet_repository.dart';
import 'package:fleet_watch/app/bloc/connectivity_bloc.dart';
import 'package:fleet_watch/car_detail/bloc/car_detail_bloc.dart';
import 'package:fleet_watch/home/bloc/home_bloc.dart';
import 'package:fleet_watch/l10n/arb/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFleetRepository extends Mock implements FleetRepository {}

extension PumpApp on WidgetTester {
  Future<void> pumpApp(
    Widget widget, {
    GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey,
    List<NavigatorObserver>? navigatorObservers,
    FleetRepository? fleetRepository,
    ConnectivityBloc? connectivityBloc,
    HomeBloc? homeBloc,
    CarDetailBloc? carDetailBloc,
  }) {
    final repository = fleetRepository ?? MockFleetRepository();
    final connectivity = connectivityBloc ?? ConnectivityBloc();
    final map = homeBloc ?? HomeBloc(repository: repository);
    final carDetail = carDetailBloc ?? CarDetailBloc(repository: repository);

    return pumpWidget(
      RepositoryProvider<FleetRepository>.value(
        value: repository,
        child: MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => connectivity),
            BlocProvider(create: (_) => map),
            BlocProvider(create: (_) => carDetail),
          ],
          child: MaterialApp(
            navigatorObservers: navigatorObservers ?? [],
            scaffoldMessengerKey: scaffoldMessengerKey,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: widget,
          ),
        ),
      ),
    );
  }
}
