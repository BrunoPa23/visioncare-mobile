import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:visioncare_app/core/constants/app_colors.dart';

class AppTextLabelStyle {
  static final style = GoogleFonts.openSans(
    textStyle: TextStyle(
      fontSize: 24, 
      fontWeight: FontWeight.w600,
      color: AppColors.textColor),
  );
}