import '../errors/app_exception.dart';

/// Converts exceptions into user-facing safe messages.
///
/// Never show raw Dio/HTML/stack traces to users.
class UiErrorMessage {
  static String from(Object error) {
    if (error is AppException) return error.message;

    // Fallback: don't leak internal details.
    return 'Something went wrong. Please try again.';
  }
}
