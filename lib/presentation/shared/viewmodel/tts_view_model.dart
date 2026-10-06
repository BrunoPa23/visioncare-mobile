import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

enum TtsState { playing, stopped, paused, continued }

final ttsViewModelProvider = ChangeNotifierProvider<TTSViewModel>((ref) {
  return TTSViewModel();
});

class TTSViewModel extends ChangeNotifier{
  final FlutterTts flutterTts = FlutterTts();

  String? language;
  String? engine;
  double volume = 1;
  double pitch = 1;
  double rate = 0.5;
  bool isCurrentLanguageInstalled = false;
  String? _newVoiceText;

  TtsState ttsState = TtsState.stopped;

  bool get isPlaying => ttsState == TtsState.playing;
  bool get isStopped => ttsState == TtsState.stopped;
  bool get isPaused => ttsState == TtsState.paused;
  bool get isContinued => ttsState == TtsState.continued;

  Future<dynamic> _getLanguages() async => await flutterTts.getLanguages;

  Future<dynamic> _getEngines() async => await flutterTts.getEngines;

  Future<void> _getDefaultEngine() async {
    var engine = await flutterTts.getDefaultEngine;
    if (engine != null) {
      print(engine);
    }
  }

  Future<void> _getDefaultVoice() async {
    var voice = await flutterTts.getDefaultVoice;
    if (voice != null) {
      print(voice);
    }
  }

  TTSViewModel() {
    flutterTts.setStartHandler(() {
      ttsState = TtsState.playing;
      notifyListeners();
    });

    flutterTts.setCompletionHandler(() {
      ttsState = TtsState.stopped;
      notifyListeners();
    });

    flutterTts.setCancelHandler(() {
      ttsState = TtsState.stopped;
      notifyListeners();
    });

    flutterTts.setPauseHandler(() {
      ttsState = TtsState.paused;
      notifyListeners();
    });
  }

  Future<void> setStartHandler(String text) async {
    List<dynamic> voices = await flutterTts.getVoices;
    print(voices);
    await flutterTts.setLanguage("es-ES");
    await flutterTts.setSpeechRate(rate); // Opcional
    await flutterTts.setVolume(volume);
    await flutterTts.setPitch(pitch);
    await flutterTts.speak(text);
    notifyListeners();
  }

  Future<void> setStopHandler() async {
    await flutterTts.stop();
    notifyListeners();
  }

  Future<void> setPauseHandler() async {
    await flutterTts.pause();
    notifyListeners();
  }



  //VOLUME
  Future<void> increaseVolume() async {
    volume += 0.1;
    if (volume > 1) {
      volume = 1;
    }
    await flutterTts.setVolume(volume);
    notifyListeners();
  }

  Future<void> decreaseVolume() async {
    volume -= 0.1;
    if (volume < 0) {
      volume = 0;
    }
    await flutterTts.setVolume(volume);
    notifyListeners();
  }

  //PITCH
  Future<void> increasePitch() async {
    pitch += 0.1;
    if (pitch > 2) {
      pitch = 2;
    }
    await flutterTts.setPitch(pitch);
    notifyListeners();
  }

  Future<void> decreasePitch() async {
    pitch -= 0.1;
    if (pitch < 0.5) {
      pitch = 0.5;
    }
    await flutterTts.setPitch(pitch);
    notifyListeners();
  }

  //RATE
  Future<void> increaseRate() async {
    rate += 0.1;
    if (rate > 2) {
      rate = 2;
    }
    await flutterTts.setSpeechRate(rate);
    notifyListeners();
  }

  Future<void> decreaseRate() async {
    rate -= 0.1;
    if (rate < 0.5) {
      rate = 0.5;
    }
    await flutterTts.setSpeechRate(rate);
    notifyListeners();
  }
}