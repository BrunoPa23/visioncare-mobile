import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:visioncare_app/core/network/api_client.dart';
import 'package:visioncare_app/core/network/api_exception.dart';

final visionServiceProvider = Provider<VisionService>((ref) {
  return VisionService(ref.watch(apiClientProvider));
});

class VisionService {
  static const path = '/vc/v1/vision/recognize-image';

  final ApiClient _api;

  VisionService(this._api);

  /// Envia la foto al backend (OCR) y devuelve el texto reconocido.
  /// Lanza [ApiException] con un mensaje legible si el backend la rechaza o no responde.
  Future<String> recognizeImage(XFile? image) async {
    if (image == null) throw const ApiException('No se eligió ninguna imagen.');

    final formData = FormData.fromMap({
      // 'imageRequest' es el nombre del campo que espera el backend
      'imageRequest': await MultipartFile.fromFile(
        image.path,
        filename: image.name,
        contentType: imageContentType(image.path),
      ),
    });

    final response = await _api.post(path, data: formData);
    final data = response.data;
    return (data is Map ? data['data'] as String? : null) ?? 'No text recognized';
  }

  /// El backend valida el tipo declarado de la imagen; sin contentType llegaria como application/octet-stream.
  static DioMediaType imageContentType(String path) {
    final extension = path.split('.').last.toLowerCase();
    final subtype = switch (extension) { 'png' => 'png', 'webp' => 'webp', _ => 'jpeg' };
    return DioMediaType('image', subtype);
  }
}
