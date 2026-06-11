/// Exceptions thrown by the data layer.
/// These are caught and converted to [Failure] objects in repositories.

class AppException implements Exception {
  const AppException({
    required this.message,
    this.code,
    this.statusCode,
  });

  final String message;
  final String? code;
  final int? statusCode;

  @override
  String toString() => 'AppException($code): $message';
}

class NetworkException extends AppException {
  const NetworkException({
    super.message = 'Network error',
    super.code = 'network_error',
  });
}

class TimeoutException extends AppException {
  const TimeoutException({
    super.message = 'Request timed out',
    super.code = 'timeout',
  });
}

class ServerException extends AppException {
  const ServerException({
    required super.message,
    super.code,
    required super.statusCode,
  });
}

class UnauthorizedException extends AppException {
  const UnauthorizedException({
    super.message = 'Unauthorized',
    super.code = 'unauthorized',
    super.statusCode = 401,
  });
}

class ForbiddenException extends AppException {
  const ForbiddenException({
    super.message = 'Forbidden',
    super.code = 'forbidden',
    super.statusCode = 403,
  });
}

class NotFoundException extends AppException {
  const NotFoundException({
    super.message = 'Not found',
    super.code = 'not_found',
    super.statusCode = 404,
  });
}

class CacheException extends AppException {
  const CacheException({
    super.message = 'Cache error',
    super.code = 'cache_error',
  });
}

class FirebaseAuthException extends AppException {
  const FirebaseAuthException({
    required super.message,
    required String firebaseCode,
  }) : super(code: firebaseCode);
}
