import 'package:flutter/material.dart';
import 'package:visioncare_app/core/constants/app_colors.dart';

class AppLoadingIndicator extends StatelessWidget {
  final double? scale;
  final double? strokeWidth;

  const AppLoadingIndicator({
    super.key,
    this.scale,
    this.strokeWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale ?? 2.0,
      child: CircularProgressIndicator(
        color: AppColors.primaryColor,
        strokeWidth: strokeWidth ?? 8.0,
      ),
    );
  }
}
