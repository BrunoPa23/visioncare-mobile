import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visioncare_app/core/network/api_client.dart';
import 'package:visioncare_app/core/network/api_exception.dart';
import 'package:visioncare_app/enums/error_auth_type_enum.dart';
import 'package:visioncare_app/presentation/login/viewmodel/login_view_model.dart';
import 'package:visioncare_app/services/auth_service.dart';

import '../helpers/fake_http.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late InMemoryTokenStorage tokens;

  setUp(() {
    tokens = InMemoryTokenStorage();
    FlutterSecureStorage.setMockInitialValues({});
  });

  AuthService buildService(FakeAdapter adapter) => AuthService(
        ApiClient(tokenStorage: tokens, baseUrl: 'http://backend.test', adapter: adapter),
        tokens,
      );

  FakeResponse signInOk(RequestOptions options) {
    if (options.path.endsWith('/auth-user/me')) return const FakeResponse(200, body: {'id': 'u-1'});
    return const FakeResponse(200, setCookies: ['AuthToken=jwt', 'RefreshToken=refresh']);
  }

  FakeAdapter offlineAdapter() => FakeAdapter((_) => const FakeResponse(200))
    ..throwOnFetch = DioException.connectionError(
      requestOptions: RequestOptions(path: '/vc/v1/authentication/sign-in'),
      reason: 'Connection refused',
    );

  group('AuthService.login', () {
    test('devuelve true y guarda la sesion con credenciales correctas', () async {
      final result = await buildService(FakeAdapter(signInOk)).login('maria@correo.com', 'clave#2026');

      expect(result, isTrue);
      expect(tokens.accessToken, 'jwt');
    });

    test('devuelve false cuando el backend responde 401', () async {
      final adapter = FakeAdapter((_) => const FakeResponse(401, body: {'message': 'Usuario o contraseña incorrectos'}));

      expect(await buildService(adapter).login('maria@correo.com', 'clave#2026'), isFalse);
    });

    test('lanza un error de conexion en lugar de devolver false', () async {
      final service = buildService(offlineAdapter());

      await expectLater(
        service.login('maria@correo.com', 'clave#2026'),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'statusCode', isNull)),
      );
    });

    test('lanza el error del limite de intentos (429)', () async {
      final adapter = FakeAdapter((_) => const FakeResponse(429));

      await expectLater(
        buildService(adapter).login('maria@correo.com', 'clave#2026'),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'statusCode', 429)),
      );
    });
  });

  group('LoginViewModel', () {
    Future<LoginViewModel> loginWith(FakeAdapter adapter) async {
      final vm = LoginViewModel(buildService(adapter));
      vm.emailController.text = 'maria@correo.com';
      vm.passwordController.text = 'clave#2026';
      await vm.login();
      return vm;
    }

    test('con credenciales incorrectas dice que la contrasena no coincide', () async {
      final vm = await loginWith(FakeAdapter((_) => const FakeResponse(401)));

      expect(vm.hasBadLogin, isTrue);
      expect(vm.isLoading, isFalse);
      expect(vm.errorAuthType, ErrorAuthType.invalidCredentials);
      expect(vm.errorMessage, contains('no coincide'));
    });

    test('sin conexion pide revisar internet y no culpa a la contrasena', () async {
      final vm = await loginWith(offlineAdapter());

      expect(vm.hasBadLogin, isTrue);
      expect(vm.isLoading, isFalse);
      expect(vm.errorAuthType, ErrorAuthType.requestFailed);
      expect(vm.errorMessage, contains('Revisa tu conexión'));
      expect(vm.errorMessage, isNot(contains('contraseña')));
    });

    test('si el servidor falla muestra su mensaje', () async {
      final vm = await loginWith(FakeAdapter((_) => const FakeResponse(500)));

      expect(vm.errorAuthType, ErrorAuthType.requestFailed);
      expect(vm.errorMessage, 'El servidor tuvo un problema. Inténtalo más tarde.');
    });
  });
}
