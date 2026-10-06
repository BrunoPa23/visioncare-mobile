import 'package:flutter/material.dart';
import 'package:visioncare_app/core/constants/app_colors.dart';

class AppPrimaryButtonStyle {
  static final elevated = ElevatedButton.styleFrom(
    disabledBackgroundColor: AppColors.DisabledButtonColor,
    backgroundColor: AppColors.primaryColor,
    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    )
  );
}
