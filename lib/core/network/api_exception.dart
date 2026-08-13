class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException(statusCode: $statusCode, message: $message)';
}

class NetworkException extends ApiException {
  const NetworkException(super.message) : super(statusCode: 0);
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException(super.message) : super(statusCode: 401);
}

class ForbiddenException extends ApiException {
  const ForbiddenException(super.message) : super(statusCode: 403);
}

class NotFoundException extends ApiException {
  const NotFoundException(super.message) : super(statusCode: 404);
}

class ValidationException extends ApiException {
  final Map<String, dynamic>? errors;
  const ValidationException(super.message, {this.errors}) : super(statusCode: 422);
}

class ServerException extends ApiException {
  const ServerException(super.message, {super.statusCode});
}

class TimeoutException extends ApiException {
  const TimeoutException(super.message) : super(statusCode: 408);
}
