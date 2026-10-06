import 'package:flutter/material.dart';
import 'package:visioncare_app/core/constants/app_colors.dart';

class AppIconButtonStyle {
  static final button = IconButton.styleFrom(
    backgroundColor: AppColors.primaryColor,
    padding: EdgeInsets.all(10),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  );
}