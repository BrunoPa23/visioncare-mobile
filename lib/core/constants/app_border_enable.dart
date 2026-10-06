import 'package:flutter/material.dart';
import 'package:visioncare_app/core/constants/app_colors.dart';

class AppBorderEnable {
  static final borderEnableTextField = OutlineInputBorder(
    borderSide: const BorderSide(
        color: AppColors.textColor,
        width: 2,
    ),
  );
}