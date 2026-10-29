class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;

  const ApiException({required this.message, this.statusCode, this.details});

  @override
  String toString() => 'ApiException(statusCode: $statusCode, message: $message)';
}

class NetworkException extends ApiException {
  final String? url;

  const NetworkException({
    super.message = 'Unable to reach institutional banking server. Check network connection.',
    this.url,
  });
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException({super.message = 'Session expired or biometric token invalid. Please re-authenticate.'})
      : super(statusCode: 401);
}

class InsufficientFundsException extends ApiException {
  const InsufficientFundsException({super.message = 'Transfer rejected: Insufficient cleared funds in account.'})
      : super(statusCode: 422);
}

class DuplicateTransactionException extends ApiException {
  final String idempotencyKey;

  const DuplicateTransactionException({
    required this.idempotencyKey,
    super.message = 'Duplicate transfer detected and prevented. Idempotency key already processed.',
  }) : super(statusCode: 409);
}

class ServerException extends ApiException {
  const ServerException({super.message = 'Internal ledger server error. Please retry shortly.'})
      : super(statusCode: 500);
}

class EmailNotVerifiedException extends ApiException {
  final String email;
  final String fullName;

  const EmailNotVerifiedException({
    required this.email,
    this.fullName = '',
    super.message = 'Your email has not been verified yet. Please enter the verification code sent to your email.',
  }) : super(statusCode: 403);
}
