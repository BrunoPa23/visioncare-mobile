import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visioncare_app/enums/request_type_enum.dart';
import 'package:visioncare_app/models/medicines.dart';
import 'package:visioncare_app/services/open_ai_service.dart';


final sideEffectsViewModelProvider = FutureProvider.family<Medicines, String>((ref, searchQuery) async {
  final openAiService = OpenAiService();
  final response = await openAiService.generateInformation(RequestTypeEnum.efectosSecundarios, searchQuery, );
  return response;
}); 