import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:visioncare_app/core/network/api_client.dart';
import 'package:visioncare_app/core/network/api_exception.dart';
import 'package:visioncare_app/core/network/token_storage.dart';
import 'package:visioncare_app/models/user.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(apiClientProvider), ref.watch(tokenStorageProvider));
});

class AuthService {
  static const _basePath = '/vc/v1';

  final ApiClient _api;
  final TokenStorage _tokens;
  final FlutterSecureStorage _secureStorage;

  AuthService(this._api, this._tokens, [this._secureStorage = const FlutterSecureStorage()]);

  Future<bool> checkTokenExpired() async {
    final authToken = await _tokens.readAccessToken();
    if (authToken == null) return true;
    final isExpired = JwtDecoder.isExpired(authToken);
    debugPrint('Token expira: ${JwtDecoder.getExpirationDate(authToken)}, vencido: $isExpired');
    return isExpired;
  }

  /// Inicia sesion; el ApiClient guarda los tokens que el backend envia como cookies.
  ///
  /// Devuelve false solo si el correo o la contrasena son incorrectos (401). Los errores de red,
  /// del servidor o por exceso de intentos se lanzan como [ApiException] con su mensaje.
  Future<bool> login(String email, String password) async {
    try {
      await _api.post(
        '$_basePath/authentication/sign-in',
        data: {'email': email, 'password': password},
        authenticated: false,
      );
    } on ApiException catch (e) {
      debugPrint('Error al iniciar sesion: ${e.statusCode} ${e.message}');
      if (e.isUnauthorized) return false;
      rethrow;
    }
    await getProfile();
    return true;
  }

  Future<bool> isUserLoggedIn() async {
    try {
      await _api.get('$_basePath/auth-user/me');
      return true;
    } on ApiException {
      return false;
    }
  }

  Future<void> getProfile() async {
    final response = await _api.get('$_basePath/auth-user/me');
    final userId = response.data['id'] as String?;
    if (userId == null) throw const ApiException('No se pudo obtener tu perfil.');
    await _secureStorage.write(key: SecureTokenStorage.userIdKey, value: userId);
  }

  Future<bool> refreshToken() => _api.refreshSession();

  /// Cierra la sesion en el backend y siempre borra la sesion local, aunque el backend no responda.
  Future<bool> signOut() async {
    try {
      await _api.post('$_basePath/authentication/sign-out', sendRefreshToken: true);
    } on ApiException catch (e) {
      debugPrint('No se pudo cerrar la sesion en el servidor: ${e.message}');
    }
    await _tokens.clear();
    return true;
  }

  Future<bool> signUp(User user) async {
    try {
      await _api.post(
        '$_basePath/authentication/sign-up',
        data: user.toJson(),
        authenticated: false,
      );
      return await login(user.email!, user.password!);
    } on ApiException catch (e) {
      debugPrint('Error al registrarse: ${e.statusCode} ${e.message}');
      return false;
    }
  }
}
