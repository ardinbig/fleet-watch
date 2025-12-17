import 'package:fleet_repository/fleet_repository.dart';
import 'package:fleet_watch/app/app.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void bootstrap() {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    log.e(details.exceptionAsString(), stackTrace: details.stack);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    log.e(error.toString(), stackTrace: stack);
    return true;
  };

  Bloc.observer = const AppBlocObserver();
  runApp(const App(createFleetRepository: FleetRepository.new));
}
