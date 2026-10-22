import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visioncare_app/core/network/api_client.dart';
import 'package:visioncare_app/core/network/api_exception.dart';
import 'package:visioncare_app/enums/request_type_enum.dart';
import 'package:visioncare_app/models/medicines.dart';

final openAiServiceProvider = Provider<OpenAiService>((ref) {
  return OpenAiService(ref.watch(apiClientProvider));
});

class OpenAiService {
  static const path = '/vc/v1/gpt/test';

  final ApiClient _api;

  OpenAiService(this._api);

  /// Pide al backend que interprete el texto del medicamento. Si falla devuelve un
  /// medicamento con nombre 'Error' y el motivo legible en la descripcion.
  Future<Medicines> generateInformation(RequestTypeEnum type, String texto) async {
    try {
      final response = await _api.post(path, data: {'tipo': type.typeName, 'texto': texto});
      final Map<String, dynamic> data = response.data;

      final medicines = Medicines(
        name: data['medicamento'] ?? 'Error',
        expirationDate: data['expirationDate'] ?? 'No encontrada',
      );

      switch (data['tipo']) {
        case 'que_es':
          medicines.description = data['contenido'] ?? '';
        case 'efectos_secundarios':
          medicines.sideEffects = List<String>.from(data['contenido'] ?? []);
        case 'instrucciones':
          medicines.instructions = List<String>.from(data['contenido'] ?? []);
        case 'advertencias':
          medicines.warnings = List<String>.from(data['contenido'] ?? []);
      }
      return medicines;
    } on ApiException catch (e) {
      debugPrint('No se pudo obtener la informacion: ${e.statusCode} ${e.message}');
      return Medicines(name: 'Error', description: 'No se pudo obtener información. ${e.message}');
    } catch (e) {
      debugPrint('Respuesta inesperada del backend: $e');
      return Medicines(name: 'Error', description: 'No se pudo obtener información');
    }
  }
}
