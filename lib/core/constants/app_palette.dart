import 'package:flutter/material.dart';
import 'package:visioncare_app/core/constants/app_colors.dart';
import 'package:visioncare_app/enums/theme_preference_enum.dart';

/// Colores de las pantallas que ya siguen el tema elegido (claro u oscuro).
/// Todos los textos cumplen al menos 4.5:1 de contraste con su fondo.
class AppPalette {
  final bool isDark;
  final Color background;
  final Color surface;
  final Color text;
  final Color border;
  final Color focus;
  final Color secondaryAction;
  final Color disabled;
  final Color disabledText;
  final Color errorBorder;
  final Color errorBackground;
  final Color errorText;

  const AppPalette._({
    required this.isDark,
    required this.background,
    required this.surface,
    required this.text,
    required this.border,
    required this.focus,
    required this.secondaryAction,
    required this.disabled,
    required this.disabledText,
    required this.errorBorder,
    required this.errorBackground,
    required this.errorText,
  });

  static const light = AppPalette._(
    isDark: false,
    background: AppColors.backgroundColor,
    surface: Color(0xFFFFFFFF),
    text: AppColors.textColor,
    border: AppColors.textColor,
    focus: AppColors.secondaryColor,
    secondaryAction: AppColors.secondaryColor,
    disabled: Color(0xFFCECECE),
    disabledText: Color(0xFF4A4A4A),
    errorBorder: Color(0xFFB3261E),
    errorBackground: Color(0xFFFDECEA),
    errorText: Color(0xFF8C1D18),
  );

  static const dark = AppPalette._(
    isDark: true,
    background: Color(0xFF0E0E0E),
    surface: Color(0xFF1C1C1C),
    text: Color(0xFFFFFFFF),
    border: Color(0xFFFFFFFF),
    focus: AppColors.primaryColor,
    secondaryAction: Color(0xFFFFFFFF),
    disabled: Color(0xFF3A3A3A),
    disabledText: Color(0xFFBDBDBD),
    errorBorder: Color(0xFFFF8A80),
    errorBackground: Color(0xFF2A0F0F),
    errorText: Color(0xFFFFE1DD),
  );

  static AppPalette resolve(ThemePreference preference, Brightness platformBrightness) {
    switch (preference) {
      case ThemePreference.dark:
        return dark;
      case ThemePreference.system:
        return platformBrightness == Brightness.dark ? dark : light;
      case ThemePreference.light:
        return light;
    }
  }
}
