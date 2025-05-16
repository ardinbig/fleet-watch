import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

/// Logger instance for logging requests, responses, and errors.
final log = Logger(printer: PrettyPrinter(methodCount: 0));

/// {@template app_interceptors}
/// Interceptors for Dio to handle request and response logging.
/// {@endtemplate}
class AppInterceptors extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    log.d('REQUEST[${options.method}] => PATH: ${options.path}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final path = response.requestOptions.path;
    log.d('RESPONSE[${response.statusCode}] => PATH: $path');
    super.onResponse(response, handler);
  }

  @override
  Future<dynamic> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final path = err.requestOptions.path;
    log.e('ERROR[${err.response?.statusCode}] => PATH: $path');
    super.onError(err, handler);
  }
}
