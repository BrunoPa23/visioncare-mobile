import 'package:dio/dio.dart';

/// Error de una llamada al backend con un mensaje que se puede mostrar o leer en voz alta.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  bool get isUnauthorized => statusCode == 401;

  /// Traduce un error de Dio a un mensaje legible. Si el backend responde con
  /// ProblemDetails se usa su `title`.
  factory ApiException.fromDio(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const ApiException('El servidor tardó demasiado en responder. Inténtalo otra vez.');
      case DioExceptionType.connectionError:
        return const ApiException('No se pudo conectar con el servidor. Revisa tu conexión a internet.');
      case DioExceptionType.cancel:
        return const ApiException('La solicitud se canceló.');
      case DioExceptionType.badCertificate:
        return const ApiException('No se pudo verificar la conexión segura con el servidor.');
      case DioExceptionType.badResponse:
        final status = error.response?.statusCode;
        return ApiException(
          _messageFromBody(error.response?.data) ?? _messageFromStatus(status),
          statusCode: status,
        );
      case DioExceptionType.unknown:
        return const ApiException('No se pudo conectar con el servidor. Revisa tu conexión a internet.');
    }
  }

  static String? _messageFromBody(Object? data) {
    if (data is! Map) return null;
    for (final key in const ['title', 'message', 'error']) {
      final value = data[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
    return null;
  }

  static String _messageFromStatus(int? status) {
    if (status == null) return 'Ocurrió un error inesperado. Inténtalo otra vez.';
    if (status == 400) return 'Los datos enviados no son válidos.';
    if (status == 401) return 'Tu sesión expiró. Inicia sesión otra vez.';
    if (status == 403) return 'No tienes permiso para hacer esta acción.';
    if (status == 404) return 'No se encontró lo que buscabas.';
    if (status == 413) return 'La imagen es demasiado grande.';
    if (status == 429) return 'Hiciste demasiadas solicitudes. Espera un momento.';
    if (status >= 500) return 'El servidor tuvo un problema. Inténtalo más tarde.';
    return 'Ocurrió un error inesperado (código $status).';
  }

  @override
  String toString() => message;
}
