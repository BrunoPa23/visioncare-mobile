import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:visioncare_app/core/network/api_client.dart';
import 'package:visioncare_app/core/network/api_exception.dart';
import 'package:visioncare_app/services/vision_service.dart';

import '../helpers/fake_http.dart';

void main() {
  late Directory tempDir;

  setUp(() => tempDir = Directory.systemTemp.createTempSync('vision_service_test'));
  tearDown(() => tempDir.deleteSync(recursive: true));

  XFile fakeImage(String name) {
    final file = File('${tempDir.path}/$name')..writeAsBytesSync([0x89, 0x50, 0x4E, 0x47]);
    return XFile(file.path);
  }

  VisionService buildService(FakeAdapter adapter) => VisionService(ApiClient(
        tokenStorage: InMemoryTokenStorage(accessToken: 'token'),
        baseUrl: 'http://backend.test',
        adapter: adapter,
      ));

  test('envia la imagen como multipart con su tipo de imagen', () async {
    final adapter = FakeAdapter((_) => const FakeResponse(200, body: {'data': 'PARACETAMOL 500 mg'}));

    final text = await buildService(adapter).recognizeImage(fakeImage('caja.png'));

    expect(text, 'PARACETAMOL 500 mg');
    final request = adapter.requests.single;
    expect(request.path, VisionService.path);
    expect(request.headers['Authorization'], 'Bearer token');
    final file = (request.data as FormData).files.single;
    expect(file.key, 'imageRequest');
    expect(file.value.contentType.toString(), 'image/png');
  });

  test('usa image/jpeg para las extensiones que no son png ni webp', () {
    expect(VisionService.imageContentType('/fotos/caja.JPG').toString(), 'image/jpeg');
    expect(VisionService.imageContentType('/fotos/caja.webp').toString(), 'image/webp');
  });

  test('si el backend rechaza la imagen lanza el title de ProblemDetails', () async {
    final adapter = FakeAdapter((_) => const FakeResponse(400, body: {'title': 'La imagen no es válida', 'status': 400}));

    await expectLater(
      buildService(adapter).recognizeImage(fakeImage('caja.jpg')),
      throwsA(isA<ApiException>().having((e) => e.message, 'message', 'La imagen no es válida')),
    );
  });
}
