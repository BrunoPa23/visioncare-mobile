// lib/presentation/shared/viewmodel/theme_preference_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visioncare_app/enums/theme_preference_enum.dart';

final themePreferenceProvider = StateNotifierProvider<ThemePreferenceNotifier, ThemePreference>((ref) {
  return ThemePreferenceNotifier()..loadPreference();
});

class ThemePreferenceNotifier extends StateNotifier<ThemePreference> {
  static const _key = 'theme_preference';
  ThemePreferenceNotifier() : super(ThemePreference.light);

  Future<void> loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    state = ThemePreference.values.firstWhere(
      (preference) => preference.name == saved,
      orElse: () => ThemePreference.light,
    );
  }

  Future<void> set(ThemePreference value) async {
    state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, value.name);
  }
}
