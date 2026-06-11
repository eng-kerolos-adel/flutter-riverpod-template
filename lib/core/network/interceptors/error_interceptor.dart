import 'package:dio/dio.dart';

import '../../errors/exceptions.dart';
import '../../utils/logger.dart';

/// Converts Dio errors into typed [AppException]s.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.error('HTTP Error', err, err.stackTrace);

    final exception = switch (err.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.sendTimeout =>
        const TimeoutException(),
      DioExceptionType.connectionError => const NetworkException(),
      DioExceptionType.badResponse => _handleStatusCode(err),
      _ => AppException(message: err.message ?? 'Unknown error'),
    };

    handler.next(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: exception,
        message: exception.message,
      ),
    );
  }

  AppException _handleStatusCode(DioException err) {
    final status = err.response?.statusCode ?? 0;
    final data = err.response?.data;
    final message = _extractMessage(data);

    return switch (status) {
      400 => AppException(message: message ?? 'Bad request', statusCode: 400),
      401 => const UnauthorizedException(),
      403 => const ForbiddenException(),
      404 => const NotFoundException(),
      422 => AppException(
          message: message ?? 'Validation failed',
          code: 'validation_error',
          statusCode: 422,
        ),
      >= 500 => ServerException(
          message: message ?? 'Server error. Please try again later.',
          statusCode: status,
        ),
      _ => AppException(message: message ?? 'Unexpected error', statusCode: status),
    };
  }

  String? _extractMessage(dynamic data) {
    if (data == null) return null;
    if (data is Map) {
      return data['message'] as String? ??
          data['error'] as String? ??
          data['detail'] as String?;
    }
    return null;
  }
}
