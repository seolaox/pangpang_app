abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => 'AppException: $message';
}

class ServerException extends AppException {
  final int? statusCode;

  const ServerException({
    required String message,
    this.statusCode,
    String? code,
    dynamic originalError,
  }) : super(
          message: message,
          code: code ?? 'SERVER_ERROR',
          originalError: originalError,
        );

  factory ServerException.fromStatusCode(int statusCode, String message) {
    return ServerException(
      message: message,
      statusCode: statusCode,
      code: 'HTTP_$statusCode',
    );
  }

  @override
  String toString() => 'ServerException($statusCode): $message';
}

class NetworkException extends AppException {
  const NetworkException(String message)
      : super(
          message: message,
          code: 'NETWORK_ERROR',
        );

  @override
  String toString() => 'NetworkException: $message';
}

class CacheException extends AppException {
  const CacheException(String message)
      : super(
          message: message,
          code: 'CACHE_ERROR',
        );

  @override
  String toString() => 'CacheException: $message';
}

class AuthException extends AppException {
  const AuthException(String message)
      : super(
          message: message,
          code: 'AUTH_ERROR',
        );

  @override
  String toString() => 'AuthException: $message';
}

class ValidationException extends AppException {
  const ValidationException(String message)
      : super(
          message: message,
          code: 'VALIDATION_ERROR',
        );

  @override
  String toString() => 'ValidationException: $message';
}