class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({
    required this.message,
    this.statusCode,
  });

  @override
  String toString() => 'ServerException: $message';
}

class NetworkException implements Exception {
  final String message;

  const NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

class CacheException implements Exception {
  final String message;

  const CacheException(this.message);

  @override
  String toString() => 'CacheException: $message';
}