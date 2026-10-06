import 'package:flutter/material.dart';
import 'package:visioncare_app/core/constants/app_colors.dart';

class AppSecondaryButtonStyle {
  static final elevated = ElevatedButton.styleFrom(
    backgroundColor: AppColors.cancelColor,
    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    )
  );
}