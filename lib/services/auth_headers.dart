import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Headers con el token JWT guardado al iniciar sesion, para las llamadas que exigen autenticacion.
Future<Map<String, String>> authHeaders([Map<String, String> extra = const {}]) async {
  final token = await const FlutterSecureStorage().read(key: 'AuthToken');
  return {
    ...extra,
    if (token != null) 'Authorization': 'Bearer $token',
  };
}
