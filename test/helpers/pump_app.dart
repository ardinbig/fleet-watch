import 'package:fleet_repository/fleet_repository.dart';
import 'package:fleet_watch/l10n/arb/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFleetRepository extends Mock implements FleetRepository {}

extension PumpApp on WidgetTester {
  Future<void> pumpApp(Widget widget, {FleetRepository? fleetRepository}) {
    return pumpWidget(
      RepositoryProvider.value(
        value: fleetRepository ?? MockFleetRepository(),
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: widget),
        ),
      ),
    );
  }
}
