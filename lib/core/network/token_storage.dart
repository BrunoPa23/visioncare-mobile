import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Guarda los tokens de la sesion. Se abstrae para poder usar una version en memoria en los tests.
abstract class TokenStorage {
  Future<String?> readAccessToken();
  Future<String?> readRefreshToken();
  Future<void> saveTokens({String? accessToken, String? refreshToken});
  Future<void> clear();
}

/// Implementacion real sobre flutter_secure_storage. Mantiene las claves que ya usan el router y el inicio.
class SecureTokenStorage implements TokenStorage {
  static const accessTokenKey = 'AuthToken';
  static const refreshTokenKey = 'RefreshToken';
  static const userIdKey = 'UserId';

  final FlutterSecureStorage _storage;

  const SecureTokenStorage([this._storage = const FlutterSecureStorage()]);

  @override
  Future<String?> readAccessToken() => _storage.read(key: accessTokenKey);

  @override
  Future<String?> readRefreshToken() => _storage.read(key: refreshTokenKey);

  @override
  Future<void> saveTokens({String? accessToken, String? refreshToken}) async {
    if (accessToken != null) await _storage.write(key: accessTokenKey, value: accessToken);
    if (refreshToken != null) await _storage.write(key: refreshTokenKey, value: refreshToken);
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: accessTokenKey);
    await _storage.delete(key: refreshTokenKey);
    await _storage.delete(key: userIdKey);
  }
}
