import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Stores sensitive auth material.
///
/// We keep this minimal and focused on token(s) needed for API calls.
class SecureTokenStorage {
  SecureTokenStorage(this._storage);

  final FlutterSecureStorage _storage;

  static const _kAccessTokenKey = 'access_token';

  Future<String?> readAccessToken() => _storage.read(key: _kAccessTokenKey);

  Future<void> writeAccessToken(String token) => _storage.write(key: _kAccessTokenKey, value: token);

  Future<void> deleteAccessToken() => _storage.delete(key: _kAccessTokenKey);

  Future<void> clearAll() => _storage.deleteAll();
}
