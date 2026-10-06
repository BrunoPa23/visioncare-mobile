import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:visioncare_app/presentation/shared/voice/voice_command_handler.dart';

final speechViewModelProvider = ChangeNotifierProvider<SpeechViewModel>((ref) {
  return SpeechViewModel()..initialize();
});

class SpeechViewModel extends ChangeNotifier {
  final SpeechToText _speech = SpeechToText();

  bool _isAvailable = false;
  bool _isListening = false;
  String _lastWords = '';

  VoiceCommandHandler? _handler;
  BuildContext? _context;
  TextEditingController? _controller;

  bool get isAvailable => _isAvailable;
  bool get isListening => _isListening;
  String get lastWords => _lastWords;

  void setCommandHandler(VoiceCommandHandler handler, BuildContext context, {TextEditingController? controller}) {
    _controller = controller ?? TextEditingController();
    _handler = handler;
    _context = context;
  }

  Future<void> initialize() async {
    _isAvailable = await _speech.initialize();
    notifyListeners();
  }

  Future<void> startListening() async {
    if (!_isAvailable || _isListening) return;

    _isListening = true;
    notifyListeners();

    await _speech.listen(
      onResult: _onSpeechResult,
      listenFor: const Duration(seconds: 20),
      pauseFor: const Duration(seconds: 5),
      localeId: 'es_ES',
    );
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    _lastWords = result.recognizedWords;
    notifyListeners();

    if (_handler != null && _context != null) {
      _handler!.handle(_lastWords, _context!, controller: _controller);
    }
  }

  Future<void> stopListening() async {
    if (_isListening) {
      await _speech.stop();
      _isListening = false;
      notifyListeners();
    }
  }
}
