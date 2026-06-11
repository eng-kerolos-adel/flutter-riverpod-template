import 'package:equatable/equatable.dart';

/// Base failure class for the domain layer.
/// All failures in the app should extend this.
abstract class Failure extends Equatable {
  const Failure({
    required this.message,
    this.code,
    this.stackTrace,
  });

  final String message;
  final String? code;
  final StackTrace? stackTrace;

  @override
  List<Object?> get props => [message, code];
}

// ─── Network Failures ──────────────────────────────────────────────
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No internet connection. Please check your network.',
    super.code = 'network_error',
    super.stackTrace,
  });
}

class TimeoutFailure extends Failure {
  const TimeoutFailure({
    super.message = 'Request timed out. Please try again.',
    super.code = 'timeout',
    super.stackTrace,
  });
}

// ─── Server Failures ───────────────────────────────────────────────
class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.code,
    this.statusCode,
    super.stackTrace,
  });

  final int? statusCode;

  @override
  List<Object?> get props => [...super.props, statusCode];
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({
    super.message = 'Session expired. Please log in again.',
    super.code = 'unauthorized',
    super.stackTrace,
  });
}

class ForbiddenFailure extends Failure {
  const ForbiddenFailure({
    super.message = 'You don\'t have permission to perform this action.',
    super.code = 'forbidden',
    super.stackTrace,
  });
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({
    super.message = 'The requested resource was not found.',
    super.code = 'not_found',
    super.stackTrace,
  });
}

// ─── Auth Failures ─────────────────────────────────────────────────
class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.code,
    super.stackTrace,
  });
}

class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure({
    super.message = 'Invalid email or password.',
    super.code = 'invalid_credentials',
    super.stackTrace,
  });
}

class EmailAlreadyInUseFailure extends Failure {
  const EmailAlreadyInUseFailure({
    super.message = 'An account with this email already exists.',
    super.code = 'email_in_use',
    super.stackTrace,
  });
}

class WeakPasswordFailure extends Failure {
  const WeakPasswordFailure({
    super.message = 'Password is too weak. Please use at least 8 characters.',
    super.code = 'weak_password',
    super.stackTrace,
  });
}

// ─── Cache Failures ────────────────────────────────────────────────
class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Failed to load cached data.',
    super.code = 'cache_error',
    super.stackTrace,
  });
}

// ─── Validation Failures ───────────────────────────────────────────
class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    super.code = 'validation_error',
    this.field,
    super.stackTrace,
  });

  final String? field;

  @override
  List<Object?> get props => [...super.props, field];
}

// ─── Unknown Failure ───────────────────────────────────────────────
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({
    super.message = 'An unexpected error occurred. Please try again.',
    super.code = 'unexpected_error',
    super.stackTrace,
  });
}
