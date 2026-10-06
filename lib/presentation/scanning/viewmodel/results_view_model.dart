// provider send image
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:visioncare_app/enums/request_type_enum.dart';
import 'package:visioncare_app/models/medicines.dart';
import 'package:visioncare_app/services/open_ai_service.dart';
import 'package:visioncare_app/services/vision_service.dart';

final resultViewModelProvider = FutureProvider.family<Medicines, XFile>((ref, imageFile) async {
  debugPrint("🔴 Flag 1: Join Provider");
  final visionService = VisionService();
  final response = await visionService.recognizeImage(imageFile);
  debugPrint("🔴 Flag 1: OCR successful, response: $response");
  final openAiService = OpenAiService();
  final result = await openAiService.generateInformation(RequestTypeEnum.queEs, response);
  debugPrint("🔴 Flag 1: OpenAI response: ${result.name}");
  return result;
});