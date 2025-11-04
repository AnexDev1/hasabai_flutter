/// Custom exception class for Hasab AI SDK errors
class HasabException implements Exception {
  /// The error message
  final String message;

  /// The HTTP status code (if applicable)
  final int? statusCode;

  /// Additional error details
  final dynamic details;

  HasabException({required this.message, this.statusCode, this.details});

  @override
  String toString() {
    if (statusCode != null) {
      return 'HasabException [$statusCode]: $message${details != null ? '\nDetails: $details' : ''}';
    }
    return 'HasabException: $message${details != null ? '\nDetails: $details' : ''}';
  }
}

/// Exception thrown when authentication fails
class HasabAuthenticationException extends HasabException {
  HasabAuthenticationException({
    super.message = 'Authentication failed. Please check your API key.',
    super.statusCode,
    super.details,
  });
}

/// Exception thrown when network request fails
class HasabNetworkException extends HasabException {
  HasabNetworkException({
    super.message = 'Network request failed.',
    super.statusCode,
    super.details,
  });
}

/// Exception thrown when file operations fail
class HasabFileException extends HasabException {
  HasabFileException({super.message = 'File operation failed.', super.details});
}

/// Exception thrown when validation fails
class HasabValidationException extends HasabException {
  HasabValidationException({
    super.message = 'Validation failed.',
    super.details,
  });
}
