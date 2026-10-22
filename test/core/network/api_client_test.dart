import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visioncare_app/core/network/api_client.dart';
import 'package:visioncare_app/core/network/api_exception.dart';

import '../../helpers/fake_http.dart';

void main() {
  late InMemoryTokenStorage tokens;
  late int sessionExpiredCalls;

  ApiClient buildClient(FakeAdapter adapter) => ApiClient(
        tokenStorage: tokens,
        baseUrl: 'http://backend.test',
        adapter: adapter,
        onSessionExpired: () => sessionExpiredCalls++,
      );

  setUp(() {
    tokens = InMemoryTokenStorage(accessToken: 'token-viejo', refreshToken: 'refresh-viejo');
    sessionExpiredCalls = 0;
  });

  test('agrega el token Bearer en las llamadas autenticadas', () async {
    final adapter = FakeAdapter((_) => const FakeResponse(200, body: {'ok': true}));
    await buildClient(adapter).get('/api/medicine/user/1');

    expect(adapter.requests.single.headers['Authorization'], 'Bearer token-viejo');
  });

  test('no agrega el token en las llamadas publicas', () async {
    final adapter = FakeAdapter((_) => const FakeResponse(200));
    await buildClient(adapter).post('/vc/v1/authentication/sign-in', data: {'email': 'a@b.com'}, authenticated: false);

    expect(adapter.requests.single.headers.containsKey('Authorization'), isFalse);
  });

  test('guarda los tokens que llegan como cookies al iniciar sesion', () async {
    tokens = InMemoryTokenStorage();
    final adapter = FakeAdapter((_) => const FakeResponse(200, setCookies: [
          'AuthToken=jwt-nuevo; expires=Thu, 01 Jan 2099 00:00:00 GMT; path=/; secure; httponly',
          'RefreshToken=refresh-nuevo; path=/; secure; httponly',
        ]));
    await buildClient(adapter).post('/vc/v1/authentication/sign-in', authenticated: false);

    expect(tokens.accessToken, 'jwt-nuevo');
    expect(tokens.refreshToken, 'refresh-nuevo');
  });

  test('envia el refresh token como cookie cuando se pide', () async {
    final adapter = FakeAdapter((_) => const FakeResponse(200));
    await buildClient(adapter).post('/vc/v1/authentication/sign-out', sendRefreshToken: true);

    expect(adapter.requests.single.headers['Cookie'], 'RefreshToken=refresh-viejo');
  });

  test('ante un 401 renueva la sesion y repite la llamada con el token nuevo', () async {
    final adapter = FakeAdapter((options) {
      if (options.path == ApiClient.refreshPath) {
        return const FakeResponse(200, setCookies: ['AuthToken=token-nuevo', 'RefreshToken=refresh-nuevo']);
      }
      final authorized = options.headers['Authorization'] == 'Bearer token-nuevo';
      return authorized ? const FakeResponse(200, body: {'id': 'abc'}) : const FakeResponse(401);
    });

    final response = await buildClient(adapter).get('/vc/v1/auth-user/me');

    expect(response.data, {'id': 'abc'});
    expect(adapter.requests.map((r) => r.path), ['/vc/v1/auth-user/me', ApiClient.refreshPath, '/vc/v1/auth-user/me']);
    expect(adapter.requests[1].headers['Cookie'], 'RefreshToken=refresh-viejo');
    expect(tokens.accessToken, 'token-nuevo');
    expect(sessionExpiredCalls, 0);
  });

  test('si la renovacion falla cierra la sesion y lanza un error legible', () async {
    final adapter = FakeAdapter((options) {
      if (options.path == ApiClient.refreshPath) {
        return const FakeResponse(401, body: {'message': 'Refresh token inválido o expirado'});
      }
      return const FakeResponse(401);
    });

    await expectLater(
      buildClient(adapter).get('/api/medicine/user/1'),
      throwsA(isA<ApiException>()
          .having((e) => e.statusCode, 'statusCode', 401)
          .having((e) => e.message, 'message', 'Tu sesión expiró. Inicia sesión otra vez.')),
    );
    expect(tokens.cleared, isTrue);
    expect(sessionExpiredCalls, 1);
  });

  test('las llamadas a la vez con 401 comparten una sola renovacion', () async {
    final adapter = FakeAdapter((options) {
      if (options.path == ApiClient.refreshPath) {
        return const FakeResponse(200, setCookies: ['AuthToken=token-nuevo']);
      }
      final authorized = options.headers['Authorization'] == 'Bearer token-nuevo';
      return authorized ? const FakeResponse(200) : const FakeResponse(401);
    });
    final client = buildClient(adapter);

    await Future.wait([client.get('/a'), client.get('/b')]);

    expect(adapter.requests.where((r) => r.path == ApiClient.refreshPath), hasLength(1));
  });

  test('un 401 en una llamada publica no intenta renovar la sesion', () async {
    final adapter = FakeAdapter((_) => const FakeResponse(401, body: {'title': 'Credenciales inválidas'}));

    await expectLater(
      buildClient(adapter).post('/vc/v1/authentication/sign-in', authenticated: false),
      throwsA(isA<ApiException>().having((e) => e.message, 'message', 'Credenciales inválidas')),
    );
    expect(adapter.requests, hasLength(1));
    expect(tokens.cleared, isFalse);
  });

  test('usa el title de ProblemDetails como mensaje', () async {
    final adapter = FakeAdapter((_) => const FakeResponse(400, body: {
          'type': 'https://tools.ietf.org/html/rfc9110#section-15.5.1',
          'title': 'La imagen debe ser JPEG, PNG o WEBP',
          'status': 400,
        }));

    await expectLater(
      buildClient(adapter).post('/vc/v1/vision/recognize-image'),
      throwsA(isA<ApiException>()
          .having((e) => e.message, 'message', 'La imagen debe ser JPEG, PNG o WEBP')
          .having((e) => e.statusCode, 'statusCode', 400)),
    );
  });

  test('sin cuerpo usa un mensaje segun el codigo de estado', () async {
    final adapter = FakeAdapter((_) => const FakeResponse(500));

    await expectLater(
      buildClient(adapter).delete('/api/medicine/1'),
      throwsA(isA<ApiException>().having((e) => e.message, 'message', 'El servidor tuvo un problema. Inténtalo más tarde.')),
    );
  });

  test('un fallo de conexion se traduce a un mensaje legible', () async {
    final adapter = FakeAdapter((_) => const FakeResponse(200))
      ..throwOnFetch = DioException.connectionError(
        requestOptions: RequestOptions(path: '/api/medicine'),
        reason: 'Connection refused',
      );

    await expectLater(
      buildClient(adapter).get('/api/medicine'),
      throwsA(isA<ApiException>().having(
        (e) => e.message,
        'message',
        'No se pudo conectar con el servidor. Revisa tu conexión a internet.',
      )),
    );
  });
}
