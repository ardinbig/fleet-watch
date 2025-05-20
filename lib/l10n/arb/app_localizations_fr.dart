// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get fleetWatchTitle => 'Fleet Watch';

  @override
  String get searchHintText => 'Rechercher par nom ou ID';

  @override
  String get filterAll => 'Tous';

  @override
  String get filterMoving => 'En mouvement';

  @override
  String get filterParked => 'Stationnés';

  @override
  String get startTracking => 'Suivre cette voiture';

  @override
  String get stopTracking => 'Arrêter le suivi';

  @override
  String get offlineTitle => 'Vous êtes hors ligne';

  @override
  String get offlineMessage =>
      'Il semble que votre appareil soit actuellement hors ligne';

  @override
  String get errorTitle => 'Une erreur s\'est produite';
}
