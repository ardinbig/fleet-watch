/// {@template fleet_api_exception}
///
/// Generic exception for FleetApi errors.
///
/// {@endtemplate}
class FleetApiException implements Exception {
  /// {@macro fleet_api_exception}
  FleetApiException(this.message, [this.code]);

  /// The error message.
  final String message;

  /// The error code.
  final int? code;

  @override
  String toString() {
    if (code != null) {
      return 'FleetApiException(code: $code, message: $message)';
    }
    return 'FleetApiException(message: $message)';
  }
}
