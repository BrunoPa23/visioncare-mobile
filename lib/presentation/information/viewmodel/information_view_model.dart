import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visioncare_app/enums/request_type_enum.dart';
import 'package:visioncare_app/models/medicines.dart';
import 'package:visioncare_app/services/open_ai_service.dart';


final searchInformationProvider = FutureProvider.family<Medicines, String>((ref, searchQuery) async {
  final openAiService = OpenAiService();
  debugPrint("🔴 ESTOY LLAMANDO API");
  final response = await openAiService.generateInformation(RequestTypeEnum.queEs, searchQuery);
  return response;
});