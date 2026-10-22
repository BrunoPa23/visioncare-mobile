import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

/// google_fonts busca cada peso como un archivo propio (OpenSans-SemiBold.ttf, etc.) y en los
/// tests no puede descargarlo. Las guias de contraste dibujan la pantalla de verdad, asi que esa
/// carga fallida rompe el test. Este helper sirve los pesos pedidos desde la fuente variable que
/// ya viene en assets/fonts, sin red.
void useBundledGoogleFonts() {
  GoogleFonts.config.allowRuntimeFetching = false;
  final assetsDir = Platform.environment['UNIT_TEST_ASSETS'];
  if (assetsDir == null) return;

  const fakeFonts = {
    'google_fonts/OpenSans-Regular.ttf': 'assets/fonts/OpenSans-VariableFont_wdth,wght.ttf',
    'google_fonts/OpenSans-SemiBold.ttf': 'assets/fonts/OpenSans-VariableFont_wdth,wght.ttf',
    'google_fonts/OpenSans-Bold.ttf': 'assets/fonts/OpenSans-VariableFont_wdth,wght.ttf',
  };

  ByteData? readAsset(String key) {
    final file = File('$assetsDir/$key');
    if (!file.existsSync()) return null;
    return Uint8List.fromList(file.readAsBytesSync()).buffer.asByteData();
  }

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler(
    'flutter/assets',
    (ByteData? message) {
      final key = Uri.decodeFull(utf8.decode(message!.buffer.asUint8List()));
      if (key == 'AssetManifest.bin') {
        final manifest = Map<Object?, Object?>.from(
          const StandardMessageCodec().decodeMessage(readAsset(key)) as Map<Object?, Object?>,
        );
        for (final fake in fakeFonts.keys) {
          manifest[fake] = [
            {'asset': fake},
          ];
        }
        return SynchronousFuture(const StandardMessageCodec().encodeMessage(manifest));
      }
      final source = fakeFonts[key];
      return SynchronousFuture(readAsset(source ?? key));
    },
  );
}
