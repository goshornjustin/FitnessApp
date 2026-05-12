/// Low-level exception types thrown by data sources.
///
/// These are thrown by data source implementations and caught by repository
/// implementations, which convert them into `Failure` subtypes (see
/// `failures.dart`) returned via `Either<Failure, T>`.
///
/// Never let these propagate past a repository — the domain layer should only
/// ever see `Failure` values, not raw exceptions.
///
/// Exception hierarchy:
/// - [ServerException] — unexpected Firestore or API error
/// - [CacheException] — Hive read/write error
/// - [NetworkException] — no internet connection
/// - [AuthException] — Firebase Auth failure (carries a human-readable message)
/// - [ValidationException] — user input failed validation rules
library;

/// Thrown when a Firestore or backend API call fails unexpectedly.
class ServerException implements Exception {
  const ServerException();
}

class CacheException implements Exception {
  const CacheException();
}

class NetworkException implements Exception {
  const NetworkException();
}

class AuthException implements Exception {
  final String message;
  
  const AuthException(this.message);
}

class ValidationException implements Exception {
  final String message;
  
  const ValidationException(this.message);
}