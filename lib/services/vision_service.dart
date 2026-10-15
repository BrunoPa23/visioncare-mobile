import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:visioncare_app/core/config/app_config.dart';
import 'package:visioncare_app/services/auth_headers.dart';

class VisionService {
  final String apiUrl;

  VisionService({this.apiUrl = '${AppConfig.apiBaseUrl}/vc/v1/vision/recognize-image'});

  Future<String> recognizeImage(XFile? image) async {
    //FormData image
    if (image == null) {
      return 'No image selected';
    }

    // El backend valida el tipo declarado de la imagen; sin contentType llegaria como application/octet-stream
    final extension = image.path.split('.').last.toLowerCase();
    final subtipo = switch (extension) { 'png' => 'png', 'webp' => 'webp', _ => 'jpeg' };

    var request = http.MultipartRequest('POST', Uri.parse(apiUrl))
        ..headers.addAll(await authHeaders())
        ..files.add(await http.MultipartFile.fromPath(
          'imageRequest', image.path, // 'file' es el nombre del campo en el servidor
          contentType: MediaType('image', subtipo),
        ));

    var response = await request.send();
    
    final responseBody = await response.stream.bytesToString();
    Map<String, dynamic> data = json.decode(responseBody);

    if (response.statusCode == 200) {
      return data['data'] ?? 'No text recognized';
    } else {
      return 'Error: ${data['error'] ?? 'Unknown error'}';
    }
  }
}