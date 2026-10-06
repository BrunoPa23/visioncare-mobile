import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:visioncare_app/enums/request_type_enum.dart';
import 'package:visioncare_app/models/medicines.dart';
import 'package:visioncare_app/core/config/app_config.dart';

class OpenAiService {
  final String apiUrl;

  OpenAiService({this.apiUrl = '${AppConfig.apiBaseUrl}/vc/v1/gpt/test'});
  
  Future<Medicines> generateInformation(RequestTypeEnum type, String texto) async {

    //POST REQUEST TO BACKEND
    final requestBody = json.encode({
      'tipo': type.typeName,
      'texto': texto,
    });

    try{
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: requestBody,
      );

      Medicines medicines = Medicines();

      if(response.statusCode == 200){
        final responseBody = response.body;
        Map<String, dynamic> data = json.decode(responseBody);
        
        medicines.name = data['medicamento'] ?? 'Error';
        medicines.expirationDate = data['expirationDate'] ?? 'No encontrada';

        if(data['tipo'] == 'que_es'){
          medicines.description = data['contenido'] ?? '';
        } 
        
        else if (data['tipo'] == 'efectos_secundarios') {
          medicines.sideEffects = List<String>.from(data['contenido'] ?? []);
        } 
        
        else if (data['tipo'] == 'instrucciones') {
          medicines.instructions = List<String>.from(data['contenido'] ?? []);
        } 
        
        else if (data['tipo'] == 'advertencias') {
          medicines.warnings = List<String>.from(data['contenido'] ?? []);
        }
        
        return medicines;

      } else {
        return Medicines(name: 'Error', description: 'No se pudo obtener información');
      }
    }
    catch (e) {
        return Medicines(name: 'Error', description: 'No se pudo obtener información');
    }
  }
}