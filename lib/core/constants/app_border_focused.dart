import 'package:flutter/material.dart';
import 'package:visioncare_app/core/constants/app_colors.dart';

class AppBorderFocused {
  static final borderFocusedTextField = OutlineInputBorder(
    borderSide: const BorderSide(
      color: AppColors.primaryColor,
      width: 2,
    ),
  );
}