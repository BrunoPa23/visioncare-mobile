// lib/presentation/shared/viewmodel/text_scale_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final textScaleProvider = StateNotifierProvider<TextScaleNotifier, double>((ref) {
  return TextScaleNotifier()..loadScale();
});

class TextScaleNotifier extends StateNotifier<double> {
  static const _key = 'text_scale';
  TextScaleNotifier() : super(1.0); 

  Future<void> loadScale() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getDouble(_key);
    if (saved != null) {
      state = saved;
    }
  }

  Future<void> _saveScale(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_key, value);
  }

  void increase() {
    if (state < 2.0) state += 0.1;
    _saveScale(state);
  }

  void decrease() {
    if (state > 1.0) state -= 0.1;
    _saveScale(state);
  }

  void reset() {
    state = 1.0;
    _saveScale(state);
  }

  void set(double value) {
    state = value.clamp(0.8, 2.0);
    _saveScale(state);
  }
}
