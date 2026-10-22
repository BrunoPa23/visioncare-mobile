import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:visioncare_app/core/network/token_storage.dart';

/// Tokens en memoria para no depender del almacenamiento seguro del telefono.
class InMemoryTokenStorage implements TokenStorage {
  String? accessToken;
  String? refreshToken;
  bool cleared = false;

  InMemoryTokenStorage({this.accessToken, this.refreshToken});

  @override
  Future<String?> readAccessToken() async => accessToken;

  @override
  Future<String?> readRefreshToken() async => refreshToken;

  @override
  Future<void> saveTokens({String? accessToken, String? refreshToken}) async {
    if (accessToken != null) this.accessToken = accessToken;
    if (refreshToken != null) this.refreshToken = refreshToken;
  }

  @override
  Future<void> clear() async {
    accessToken = null;
    refreshToken = null;
    cleared = true;
  }
}

/// Respuesta simulada del backend.
class FakeResponse {
  final int status;
  final Object? body;
  final List<String> setCookies;

  const FakeResponse(this.status, {this.body, this.setCookies = const []});
}

/// Adaptador HTTP falso: nunca sale a la red y registra cada peticion.
class FakeAdapter implements HttpClientAdapter {
  final FakeResponse Function(RequestOptions options) handler;
  final List<RequestOptions> requests = [];
  Object? throwOnFetch;

  FakeAdapter(this.handler);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    // Consumir el cuerpo cierra los archivos del multipart, como haria un adaptador real
    await requestStream?.drain<void>();
    if (throwOnFetch != null) throw throwOnFetch!;
    final response = handler(options);
    return ResponseBody.fromString(
      response.body == null ? '' : jsonEncode(response.body),
      response.status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
        if (response.setCookies.isNotEmpty) 'set-cookie': response.setCookies,
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
