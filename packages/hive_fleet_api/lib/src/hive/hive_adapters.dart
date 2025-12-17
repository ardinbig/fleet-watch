import 'package:fleet_api/fleet_api.dart';
import 'package:hive_ce/hive.dart';

part 'hive_adapters.g.dart';

@GenerateAdapters([
  AdapterSpec<Car>(),
  AdapterSpec<CarStatus>(),
])

/// This class is used to generate the Hive adapters for the models.
/// It is not meant to be used directly.
class HiveAdapters {}
