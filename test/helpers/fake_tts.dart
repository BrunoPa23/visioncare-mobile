import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visioncare_app/presentation/shared/viewmodel/speech_view_model.dart';
import 'package:visioncare_app/presentation/shared/viewmodel/tts_view_model.dart';

/// Voz falsa: guarda lo que la app quiso leer en lugar de llamar al plugin nativo.
class FakeTtsViewModel extends TTSViewModel {
  final List<String> spoken = [];

  @override
  Future<void> setStartHandler(String text) async => spoken.add(text);

  @override
  Future<void> setStopHandler() async {}
}

Override ttsOverride(FakeTtsViewModel tts) => ttsViewModelProvider.overrideWith((ref) => tts);

/// Reconocimiento de voz falso: no pide permisos ni usa el plugin nativo.
class FakeSpeechViewModel extends SpeechViewModel {
  @override
  Future<void> initialize() async {}
}
