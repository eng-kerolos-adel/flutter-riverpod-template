import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/app_constants.dart';
import '../../utils/logger.dart';
import '../../../features/auth/presentation/providers/auth_provider.dart';

/// Injects the auth token into every request.
/// On 401, attempts to refresh the token once.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._ref);

  final Ref _ref;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _getToken();

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      AppLogger.warning('Token expired, attempting refresh...');

      try {
        final refreshed = await _refreshToken();
        if (refreshed) {
          // Retry original request with new token
          final token = await _getToken();
          final opts = err.requestOptions;
          opts.headers['Authorization'] = 'Bearer $token';

          final cloneReq = await Dio().fetch(opts);
          return handler.resolve(cloneReq);
        }
      } catch (e) {
        AppLogger.error('Token refresh failed', e);
      }

      // Refresh failed → log out
      await _logout();
    }

    handler.next(err);
  }

  Future<String?> _getToken() async {
    // Read from secure storage via provider
    // TODO: inject your actual token storage provider
    return null;
  }

  Future<bool> _refreshToken() async {
    // TODO: implement token refresh logic
    return false;
  }

  Future<void> _logout() async {
    // TODO: trigger logout via auth provider
  }
}
