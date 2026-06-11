import 'package:dio/dio.dart';

import '../../utils/logger.dart';

/// Retries idempotent requests on network errors.
class RetryInterceptor extends Interceptor {
  RetryInterceptor(this._dio, {this.maxRetries = 3});

  final Dio _dio;
  final int maxRetries;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final attempt = err.requestOptions.extra['retryCount'] as int? ?? 0;
    final isNetworkError =
        err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout;
    final isIdempotent = const {'GET', 'HEAD', 'PUT', 'DELETE'}
        .contains(err.requestOptions.method.toUpperCase());

    if (isNetworkError && isIdempotent && attempt < maxRetries) {
      AppLogger.warning('Retrying request (attempt ${attempt + 1}/$maxRetries)');
      await Future.delayed(Duration(seconds: 1 << attempt)); // exponential backoff

      err.requestOptions.extra['retryCount'] = attempt + 1;
      try {
        final response = await _dio.fetch(err.requestOptions);
        return handler.resolve(response);
      } catch (e) {
        return handler.next(err);
      }
    }

    handler.next(err);
  }
}
