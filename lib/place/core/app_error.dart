class AppError {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppError({
    required this.message,
    this.code,
    this.originalError,
  });

  factory AppError.network(String message) {
    return AppError(message: message, code: 'NETWORK_ERROR');
  }

  factory AppError.server(String message) {
    return AppError(message: message, code: 'SERVER_ERROR');
  }

  factory AppError.unknown(String message) {
    return AppError(message: message, code: 'UNKNOWN_ERROR');
  }

  @override
  String toString() => 'AppError: $message';
}