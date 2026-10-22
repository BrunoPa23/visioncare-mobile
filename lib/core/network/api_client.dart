import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visioncare_app/core/config/app_config.dart';
import 'package:visioncare_app/core/network/api_exception.dart';
import 'package:visioncare_app/core/network/token_storage.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) => const SecureTokenStorage());

/// Que hacer cuando la sesion vence y no se puede renovar. main.dart lo reemplaza para volver al login.
final sessionExpiredCallbackProvider = Provider<VoidCallback>((ref) => () {});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    tokenStorage: ref.watch(tokenStorageProvider),
    onSessionExpired: ref.watch(sessionExpiredCallbackProvider),
  );
});

/// Cliente HTTP unico para el backend de VisionCare.
///
/// - Agrega `Authorization: Bearer <token>` a las llamadas autenticadas.
/// - Guarda los tokens que el backend envia como cookies (inicio de sesion y renovacion).
/// - Ante un 401 intenta renovar la sesion una vez y repite la llamada; si no puede, cierra la sesion.
/// - Convierte los errores en [ApiException] con un mensaje legible.
class ApiClient {
  static const refreshPath = '/vc/v1/authentication/refresh-token';
  static const _accessCookie = 'AuthToken';
  static const _refreshCookie = 'RefreshToken';
  static const _authenticatedKey = 'authenticated';
  static const _sendRefreshTokenKey = 'sendRefreshToken';
  static const _retriedKey = 'retried';

  final TokenStorage _tokens;
  final VoidCallback? onSessionExpired;
  final Dio dio;
  final Dio _refreshDio;
  Future<bool>? _refreshing;

  ApiClient({
    required TokenStorage tokenStorage,
    String baseUrl = AppConfig.apiBaseUrl,
    HttpClientAdapter? adapter,
    this.onSessionExpired,
  })  : _tokens = tokenStorage,
        dio = Dio(_baseOptions(baseUrl)),
        _refreshDio = Dio(_baseOptions(baseUrl)) {
    if (adapter != null) {
      dio.httpClientAdapter = adapter;
      _refreshDio.httpClientAdapter = adapter;
    }
    dio.interceptors.add(
      InterceptorsWrapper(onRequest: _onRequest, onResponse: _onResponse, onError: _onError),
    );
  }

  static BaseOptions _baseOptions(String baseUrl) => BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 60),
        headers: {'Accept': 'application/json'},
      );

  Future<Response<dynamic>> get(String path, {Map<String, dynamic>? queryParameters, bool authenticated = true}) {
    return _send(() => dio.get(
          path,
          queryParameters: queryParameters,
          options: _options(authenticated: authenticated),
        ));
  }

  /// [data] puede ser un mapa (se envia como JSON) o un [FormData] (multipart).
  Future<Response<dynamic>> post(
    String path, {
    Object? data,
    bool authenticated = true,
    bool sendRefreshToken = false,
  }) {
    return _send(() => dio.post(
          path,
          data: data,
          options: _options(authenticated: authenticated, sendRefreshToken: sendRefreshToken),
        ));
  }

  Future<Response<dynamic>> delete(String path, {bool authenticated = true}) {
    return _send(() => dio.delete(path, options: _options(authenticated: authenticated)));
  }

  /// Pide un token nuevo con el refresh token guardado. Si hay varias llamadas a la vez, se hace una sola.
  Future<bool> refreshSession() {
    return _refreshing ??= _doRefresh().whenComplete(() => _refreshing = null);
  }

  Future<bool> _doRefresh() async {
    final refreshToken = await _tokens.readRefreshToken();
    if (refreshToken == null) return false;
    try {
      final response = await _refreshDio.post(
        refreshPath,
        options: Options(headers: {'Cookie': '$_refreshCookie=$refreshToken'}),
      );
      final saved = await _saveTokensFrom(response);
      return saved.accessToken != null;
    } on DioException catch (e) {
      debugPrint('No se pudo renovar la sesion: ${e.response?.statusCode ?? e.type}');
      return false;
    }
  }

  Options _options({required bool authenticated, bool sendRefreshToken = false}) => Options(
        extra: {_authenticatedKey: authenticated, _sendRefreshTokenKey: sendRefreshToken},
      );

  Future<Response<dynamic>> _send(Future<Response<dynamic>> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> _onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (options.extra[_authenticatedKey] != false) {
      final token = await _tokens.readAccessToken();
      if (token != null) options.headers['Authorization'] = 'Bearer $token';
    }
    // El backend lee el refresh token de la cookie (por ejemplo al cerrar sesion)
    if (options.extra[_sendRefreshTokenKey] == true) {
      final refreshToken = await _tokens.readRefreshToken();
      if (refreshToken != null) options.headers['Cookie'] = '$_refreshCookie=$refreshToken';
    }
    handler.next(options);
  }

  Future<void> _onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) async {
    await _saveTokensFrom(response);
    handler.next(response);
  }

  Future<void> _onError(DioException error, ErrorInterceptorHandler handler) async {
    final options = error.requestOptions;
    final canRetry = error.response?.statusCode == 401 &&
        options.extra[_authenticatedKey] != false &&
        options.extra[_retriedKey] != true;
    if (!canRetry) {
      handler.next(error);
      return;
    }

    // Si otra llamada ya renovo el token mientras tanto, basta con repetir con el token actual
    final current = await _tokens.readAccessToken();
    final alreadyRenewed = current != null && options.headers['Authorization'] != 'Bearer $current';
    if (alreadyRenewed || await refreshSession()) {
      try {
        options.extra[_retriedKey] = true;
        options.headers['Authorization'] = 'Bearer ${await _tokens.readAccessToken()}';
        handler.resolve(await dio.fetch<dynamic>(options));
      } on DioException catch (retryError) {
        handler.next(retryError);
      }
      return;
    }

    await _tokens.clear();
    onSessionExpired?.call();
    handler.next(error);
  }

  /// Lee las cookies AuthToken y RefreshToken de la respuesta y las guarda.
  Future<({String? accessToken, String? refreshToken})> _saveTokensFrom(Response<dynamic> response) async {
    String? accessToken;
    String? refreshToken;
    for (final header in response.headers['set-cookie'] ?? const <String>[]) {
      final pair = header.split(';').first;
      final separator = pair.indexOf('=');
      if (separator <= 0) continue;
      final name = pair.substring(0, separator).trim();
      final value = pair.substring(separator + 1).trim();
      if (value.isEmpty) continue;
      if (name == _accessCookie) accessToken = value;
      if (name == _refreshCookie) refreshToken = value;
    }
    if (accessToken != null || refreshToken != null) {
      await _tokens.saveTokens(accessToken: accessToken, refreshToken: refreshToken);
    }
    return (accessToken: accessToken, refreshToken: refreshToken);
  }
}
