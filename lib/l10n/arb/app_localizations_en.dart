// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get fleetWatchTitle => 'Fleet Watch';

  @override
  String get searchHintText => 'Search by name or ID';

  @override
  String get filterAll => 'All';

  @override
  String get filterMoving => 'Moving';

  @override
  String get filterParked => 'Parked';

  @override
  String get startTracking => 'Track This Car';

  @override
  String get stopTracking => 'Stop Tracking';
}
