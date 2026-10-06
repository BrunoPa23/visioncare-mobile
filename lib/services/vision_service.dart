import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:visioncare_app/core/config/app_config.dart';

class VisionService {
  final String apiUrl;

  VisionService({this.apiUrl = '${AppConfig.apiBaseUrl}/vc/v1/vision/recognize-image'});

  Future<String> recognizeImage(XFile? image) async {
    //FormData image
    if (image == null) {
      return 'No image selected';
    }

    var request = http.MultipartRequest('POST', Uri.parse(apiUrl))
        ..files.add(await http.MultipartFile.fromPath(
          'imageRequest', image.path, // 'file' es el nombre del campo en el servidor
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